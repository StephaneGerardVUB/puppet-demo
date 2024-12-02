#!/bin/bash

# This script installs Puppet Agent on a client node and configures it to connect to a Puppet Server.
# It also classifies the node by creating a file /etc/puppetlabs/facter/facts.d/classification.yaml
# that contains the application context (app), the role it plays (role) in this application context,
# and the environment it belongs to (env).
# The script then runs the Puppet Agent for the first time to get a signed certificate.
# Finally, it enables the puppet agent service and starts it.
#
# Usage:
#   vagrant_client_install.sh <Puppet Server hostname> [app] [role] [env]
# Example:
#   vagrant_client_install.sh puppetserver.example.com slurm workernode production


# Throw an error if no params provided (mandatory: Puppet Server hostname, optional: application context, role, environment)
if [ $# -lt 1 ]; then
    echo "Usage: $0 <Puppet Server hostname> [app] [role] [env]" >&2
    exit 1
fi

# Processing arguments
PUPPET_SERVER=$1
ENC_APP=${2:-unknown}
ENC_ROLE=${3:-unknown}
ENC_ENV=${4:-production}

# A bunch of parameters
PUPPET_RELEASE_MAJOR='8'
OS_RELEASE_MAJOR='8'
GIT_ACCOUNT='StephaneGerardVUB'
GIT_REPO='puppet-demo'
PUPPET_DEFAULT_ENV='production'
CERTNAME=$(hostname -f)

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Install Puppet repository
rpm -Uvh https://yum.puppet.com/puppet${PUPPET_RELEASE_MAJOR}-release-el-${OS_RELEASE_MAJOR}.noarch.rpm

# Install Puppet Server and some other tools
yum install -y puppet-agent

# Some more packages depending on the OS major release
if [ ${OS_RELEASE_MAJOR} -eq 8 ]; then
    yum install -y redhat-lsb-core
fi
if [ ${OS_RELEASE_MAJOR} -eq 9 ]; then
    yum install -y lsb_release
fi


# Create a configuration file for Puppet Server
cat > /etc/puppetlabs/puppet/puppet.conf << EOF
[agent]
certname=${CERTNAME}
environment=${PUPPET_DEFAULT_ENV}
logdest=/var/log/puppetlabs/puppet/puppet.log
report=true
runinterval=1h
server=${PUPPET_SERVER}
EOF

# Classify the node -> creation of file /etc/puppetlabs/facter/facts.d/classification.yaml
# This file will be used by Puppet to classify the node, knowing its application context (app),
# the role it plays (role) in this application context, and the environment it belongs to (env).
mkdir -p /etc/puppetlabs/facter/facts.d
cat > /etc/puppetlabs/facter/facts.d/classification.yaml << EOF
---
app: ${ENC_APP}
role: ${ENC_ROLE}
env: ${ENC_ENV}
EOF

# First run of puppet agent -> will get a signed certificate
echo "Run puppet for the first time"
/opt/puppetlabs/puppet/bin/puppet agent -t --logdest console

# Enable puppet agent service
systemctl enable puppet
systemctl start puppet

echo "Puppet Agent installation and configuration complete."