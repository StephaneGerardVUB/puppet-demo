#!/bin/bash

# A bunch of parameters
PUPPET_RELEASE_MAJOR='8'
OS_RELEASE_MAJOR='9'
GIT_ACCOUNT='iihe'
GIT_REPO='puppet-demo'
PUPPET_DEFAULT_ENV='production'
PUPPET_SERVER=$(hostname -f)

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Install Puppet repository
rpm -Uvh https://yum.puppet.com/puppet${PUPPET_RELEASE_MAJOR}-release-el-${OS_RELEASE_MAJOR}.noarch.rpm

# Install Puppet Server and some other tools
yum install -y puppetserver git gcc rsync

# Add puppet binaries to PATH via .bash_profile
echo "export PATH=$PATH:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin" >> /root/.bash_profile

# Install r10k and hiera-eyaml
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml
/opt/puppetlabs/puppet/bin/gem install r10k

# Configure r10k
cat > /etc/puppetlabs/r10k/r10k.yaml << EOF
:cachedir: "/var/cache/r10k"
:sources:
  production:
    basedir: "/etc/puppetlabs/code/environments"
    remote: "git@gitlab.iihe.ac.be:${GIT_ACCOUNT}/${GIT_REPO}.git"
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
sed -i 's/JAVA_ARGS.*/JAVA_ARGS="-Xms512m -Xmx512m -XX:MaxPermSize=256m"/' /etc/sysconfig/puppetserver

# Set Puppet Server to start on boot
systemctl enable puppetserver

# Start Puppet Server
systemctl start puppetserver

# Configure firewall to allow Puppet traffic
firewall-cmd --permanent --add-port=8140/tcp
firewall-cmd --reload

echo "Puppet Master installation and configuration complete."