#!/bin/bash

# This script takes optional arguments:
# - Puppet release major version (default: 8)
# - OS release major version (default: 8)
# - Git account (default: StephaneGerardVUB)
# - Git repository (default: puppet-demo)
# - Default Puppet environment (default: production)


# Write a usage function
usage() {
    echo "Usage: $0 [OPTION]..."
    echo "Install and configure a Puppet Master."
    echo "  --puppet-release-major=RELEASE_MAJOR  Puppet release major version (default: 8)"
    echo "  --os-release-major=RELEASE_MAJOR      OS release major version (default: 8)"
    echo "  --git-account=ACCOUNT                 Git account (default: StephaneGerardVUB)"
    echo "  --git-repo=REPO                       Git repository (default: puppet-demo)"
    echo "  --puppet-default-env=ENV              Default Puppet environment (default: production)"
    echo "  --help                                Display this help message."
    exit 1
}

# Parse the command line options
while [ $# -gt 0 ]; do
    case "$1" in
        --help)
            usage
            ;;
        --puppet-release-major=*)
            PUPPET_RELEASE_MAJOR="${1#*=}"
            ;;
        --os-release-major=*)
            OS_RELEASE_MAJOR="${1#*=}"
            ;;
        --git-account=*)
            GIT_ACCOUNT="${1#*=}"
            ;;
        --git-repo=*)
            GIT_REPO="${1#*=}"
            ;;
        --puppet-default-env=*)
            PUPPET_DEFAULT_ENV="${1#*=}"
            ;;
        *)
            printf "***************************\n"
            printf "* Error: Invalid argument.*\n"
            printf "***************************\n"
            usage
            exit 1
    esac
    shift
done

# Default values for optional arguments
PUPPET_RELEASE_MAJOR=${PUPPET_RELEASE_MAJOR:-8}
OS_RELEASE_MAJOR=${OS_RELEASE_MAJOR:-8}
GIT_ACCOUNT=${GIT_ACCOUNT:-StephaneGerardVUB}
GIT_REPO=${GIT_REPO:-puppet-demo}
PUPPET_DEFAULT_ENV=${PUPPET_DEFAULT_ENV:-production}
PUPPET_SERVER=$(hostname -f)


# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Install Puppet repository
rpm -Uvh https://yum.puppet.com/puppet${PUPPET_RELEASE_MAJOR}-release-el-${OS_RELEASE_MAJOR}.noarch.rpm

# Install Puppet Server and some other tools
dnf install -y puppetserver git gcc rsync

# Add puppet binaries to PATH via .bash_profile
echo "export PATH=$PATH:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin" >> /root/.bash_profile
export PATH=$PATH:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin

# Install r10k and hiera-eyaml
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml
/opt/puppetlabs/puppet/bin/gem install r10k

# Configure r10k
mkdir -p /etc/puppetlabs/r10k
cat > /etc/puppetlabs/r10k/r10k.yaml << EOF
:cachedir: "/var/cache/r10k"
:sources:
  production:
    basedir: "/etc/puppetlabs/code/environments"
    remote: remote: "git@github.com:${GIT_ACCOUNT}/${GIT_REPO}.git"
EOF

# Generate SSH key for root
ssh-keygen -t rsa
# Remind the user to add the SSH key to the git repository
echo "Please add the SSH key to the git repository."
# Adding github.com to the known_hosts (required by r10k)
touch /root/.ssh/known_hosts
ssh-keygen  -R github.com
ssh-keyscan -H github.com >> /root/.ssh/known_hosts

# Create a configuration file for Puppet Server
cat > /etc/puppetlabs/puppet/puppet.conf << EOF
[server]
autosign=true
codedir=/etc/puppetlabs/code
environment=${PUPPET_DEFAULT_ENV}
logdir=/var/log/puppetlabs/puppetserver
pidfile=/var/run/puppetlabs/puppetserver/puppetserver.pid
reports=none
rundir=/var/run/puppetlabs/puppetserver
server=${PUPPET_SERVER}
storeconfigs=false
storeconfigs_backend=puppetdb
vardir=/opt/puppetlabs/server/data/puppetserver
EOF

# Configure Puppet Server memory allocation
sed -i 's/JAVA_ARGS=.*/JAVA_ARGS="-Xms2g -Xmx2g -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger"/' /etc/sysconfig/puppetserver

# Set Puppet Server to start on boot
systemctl enable puppetserver

# Start Puppet Server
systemctl start puppetserver

# Configure firewall to allow Puppet traffic
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=8140/tcp
firewall-cmd --reload

# First r10k run
r10k deploy  environment -p production

echo "Puppet Master installation and configuration complete."