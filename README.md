# puppet-demo
Typical small and simple Puppet workspace to use for demonstrations or as a starting point for real use case

## Table of Contents

- [puppet-demo](#puppet-demo)
  - [Usage](#usage)
  - [Bootstrapping for automatic enrollment](#bootstrapping-for-automatic-enrollment)
    - [Installation of the agent (RH-like only)](#installation-of-the-agent-(rh-like-only))
    - [Configuration of the agent](#configuration-of-the-agent)
  - [Node classification](#node-classification)
    - [Classification mechanism is details](#classification-mechanism-is-details)
  - [Testing puppet-demo workspace with Vagrant](#testing-puppet-demo-workspace-with-vagrant)
    - [Preparing your laptop for Vagrant](#preparing-your-laptop-for-vagrant)
    - [Instantiating the vagrant testbed](#instantiating-the-vagrant-testbed)
    - [Clean-up](#clean-up)



## Usage

Git clone this repo on the machine where you want to create an instance of puppetserver.
Adapt and run pm_install.sh to install a new puppet server.

Once the server is set up, you still have two steps to get your machines under control of Puppet:
- set up of the bootstrapping for the automatic enrollement of machines;
- to implement a solution to classify your machines.

It is natural to achieve these 2 steps with the help of the provisioning system (Foreman or Quattor or...).

## Bootstrapping for automatic enrollment

### Installation of the agent (RH-like only)
1. Add the Puppet repo file
2. Install 'puppet-agent' package
3. The facter application needs lsb_release binary:
   - Under EL8 -> package 'redhat-lsb-core'
   - Under EL9 -> package 'lsb_release'
4. Make sure service 'puppet' is enabled and on.

### Configuration of the agent

The agent configuration file is ```/etc/puppetlabs/puppet/puppet.conf``` with the following typical content:

```
[agent]
certname=<fqdn_puppet_node>
environment=production
logdest=/var/log/puppetlabs/puppet/puppet.log
report=true
runinterval=1h
server=<fqdn_pupper_server>
```


## Node classification

**Classification** has a well-defined meaning in the Puppet terminology. It must be understood as "assigning classes to nodes".
There infinite ways of doing this. The solution being considered in this project is to use the provisionning subsystem to inject a yaml files in the node in order to create custom facts. The homebrewed facts mainly consist in 3 pieces of information:
- the application context in which the machine lives (**app**);
- the role played by the machine in this context (**role**);
- the environment of the machine (**environment**).

Let's illustrate this. Consider for example an hypervizor in a production OpenNebula farm. We can then describe it like this:
* app => 'opennebula'
* role => 'hypervizor'
* environment => 'production'

With the "apps" and "roles" being declared as levels in ```hiera.yaml```, we can now assign site-classes to machines. The details of how this is precisely done will be explained below in a sub-section.

Here is the content of the yaml file that provisioning system will have to inject:

```
---
app: opennebula
role: hypervizor
env: production
```

It will be inject under the form of a *.yaml file created in the directory ```/etc/puppetlabs/facter/facts.d/```.

In order to create this yaml file automatically, if you use Quattor, you can create a ```puppet_db.pan``` in which you will declare a dictionary of dictionary, the key being the machine name, and the value being a dict with keys 'app', 'role' and 'environment'.

### Classification mechanism is details

The first *.pp file considered by the Puppet compiler will be the ```site.pp``` (see the variable ```manifest``` in configuration file ```environment.conf```). Now, if you look at the content of the site.pp file of this project, you'll find this:

```
lookup('classes', Array[String], 'unique').include
```

This code tells to Puppet to create the list 'classes' by collecting, with the hiera 'lookup' function, all the list elements found in the yaml files contained in the hiera database whose organization is described in the ```hiera.yaml``` file:

```
...
  - name: "Per-role data"
    paths:
      - "roles/%{::app}/%{::role}.yaml"

  - name: "Per-application data"
    paths:
      - "apps/%{::app}.yaml"
...
```

Now, in the ```data``` directory, you might find these yaml files:
- roles/opennebula/hypervizor.yaml
- apps/opennebula.yaml

with the following contents:

```
---
classes:
  - opennebula::hypervizor
```

```
classes:
  - opennebula::common
```

Once the lookup function has collected all the elements of the 'classes' array, it returns the array itself that is applied the 'include' method, and that amounts to have the following code in site.pp:

```
node 'hypervizor.myorg.be' {
    include opennebula::common
    include opennebula::hypervizor
}
```

### Organization of site classes

The classes have two possible origins:
- classes coming from modules (or **module-classes**);
- custom classes internal to the site (or **site-classes**).

The module-classes are not present in the Puppet workspace. They will be imported in the workspace of the puppetserver with the r10k command, because they are of course required for the compilation.

Module-classes could be included directly via the roles defined in hiera. But that's not how Puppet sysadmins use to work: they prefer to include the module-classes inside site-classes, and the latter are in turn included in the nodes via hiera. The reason behind this is that you may want to perform on machines some tasks that only make sense at the level of your site. For examples, you might need to perform some site-specific network configuration tasks, or to configure some site internal repositories,... before or after including the module classes. In summary, thanks to site-classes, sysadmins can manage pre-requisites and post-requisites.

Another important point about class organization in this project: it's based on the widely adopted 'role and profile' terminology. A role is made of several profiles. (For those who are familiar with Quattor: a Puppet profile corresponds to a Quattor feature.) On a practical level, you will understand what is a role by looking at its yaml file in hiera ('classes' is the list of profiles), and you have the details of a profile by looking the code of its classe in the code/profiles/<role> directory.


## Testing puppet-demo workspace with Vagrant

A Vagrant file was written to help you to set up a small testbed made of a puppetserver instance and some client nodes.

### Preparing your laptop for Vagrant

These explanations are valid for a Linux machine on which it is possible to create VMs using QEMU/KVM. It was tested on Fedora 39.

Run the following commands on your laptop (you must be working with a sudoers account):

```
sudo dnf install vagrant vagrant-libvirt
sudo usermod -a -G libvirt ${USER}
sudo systemctl --now enable virtnetworkd.service
sudo firewall-cmd --permanent --zone=libvirt --add-service=nfs
sudo firewall-cmd --reload
```

### Instantiating the vagrant testbed

Fork the puppet-demo project and create a local copy of it:

```
git clone https://github.com/<your_git_account>/puppet-demo.git
```

Instantiate the testbed:

```
cd puppet-demon
vagrant up
```

After a few minutes, you should get at least to VMs:
- puppetmaster.vm.local
- node1.vm.local

Check the status of these VMs with the following command:

```
vagrant status
```

You can login to them with this command:

```
vagrant ssh <vm_name>
```

You can now train yourself by trying to configure resources on the client nodes. You will find a Puppet quick start guide [here](Puppet_Quick_Start.md).

### Clean-up

When you are done with the testbed, you can remove the VMs with:

```
vagrant destroy <vm_name>
```

If you still intend to use the testbed in the future, you may want to keep the vagrant box. If you want to remove it:

```
vagrant box remove <name_vagrant_box_name>
```

To get the vagrant box name:

```
vagrant box list
```