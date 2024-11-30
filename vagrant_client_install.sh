#!/bin/bash

# Processing arguments
PUPPET_SERVER=$1

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
cat > /etc/puppetlabs/facter/facts.d/classification.yaml << EOF
---
app: slurm
role: workernode
env: production
EOF

# First run of puppet agent -> will get a signed certificate
echo "Run puppet for the first time"
/opt/puppetlabs/puppet/bin/puppet agent -t --logdest console

# Enable puppet agent service
systemctl enable puppet
systemctl start puppet

echo "Puppet Agent installation and configuration complete."