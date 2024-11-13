# puppet-demo
Typical small and simple Puppet workspace to use for demonstrations or as a starting point for real use case

Git clone this repo on the machine where you want to create an instance of puppetserver.
Adapt and run pm_install.sh to install a new puppet server.

Once the server is set up, you still have two steps to get your machines under control of Puppet:
- set up of the bootstrapping for the automatic enrollement of machines;
- to implement a solution to classify your machines.

It is natural to achieve these 2 steps with the help of the provisioning system (Foreman or Quattor or...). I will only document the Quattor case.

# Bootstrapping for automatic enrollement

# Node classification

