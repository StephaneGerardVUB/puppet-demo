# Puppet Quick Start
Essential things you need to know to start playing with Puppet

## What is Puppet?

Puppet is configuration management system to manage an IT infrastructure as a code.

## Puppet main features

* Can work in 2 modes: client-server or standalone
* Declarative language (DSL): the code describes the desired state of the machine (machine as code)
* Code written in *.pp files called **manifests**
* Puppet compiles the manifests into **catalogs** (json description of the desired state of the machines)
* Pulling paradigm: an agent running on the client machine is responsible for fetching the **catalog** and for changing the machine configuration accordingly
* Idempotent
* Support of many operating systems: AIX, AlmaLinux, Amazon Linux, CentOS, Debian, Fedora, macOS, Microsoft Windows, Microsoft Windows Server, Red Hat Enterprise Linux, Rocky Linux, Scientific Linux, Solaris, SUSE Linux Enterprise Server, Ubuntu

## Puppet basic concepts and terminology

### Resources

Puppet code is made of resource declarations. Resources are the fundamental units of the machine configuration, they are based on builtin native types (package, service, user, group,...). Each resource has a type, a name, and some attributes. They can be linked.

### Classes
Blocks of code that can be reused. They are made of resources and/or other classes. Classes are defined in the manifests. Classes are assigned to a node either using an ENC (External Node Classifier) or by declaring it in a manifest. Classes can be parametrized. Classes are linkable.

### Modules
Thematic collections of classes and their dependencies. The organization of the files is standardized. Modules can be viewed as packaging system to share classes with the communities via [**Puppet Forge**](https://forge.puppet.com/).

![https://puppet.com!](/1_DOwssrDzC5KrUG4-41cMAA.webp "Icons of resources, classes and modules")

### Environments

An environment is an isolated group of nodes. An environment can have its own set of manifests and modules. You can use environments to distinguish your production nodes from the testbeds for example. Or you can use environments to divide your site by types of hardware.

If you maintain your code using Git, you can map your environments to development branches using the **r10k** tool.

### Facts

Facts are low level pieces of information gathered on the nodes by the **facter** tool. The facts are sent to the puppetserver. Facts can be used in the code through the **$facts** dictionary.

Information collected: CPUs brands and models, amount of memory, disk partitions, network interfaces (MAC/IP addresses,...), OS release, etc.

The facts can be extended by the sysadmins using custom facts.

## Coding

## Hiera

## Integration with Git

r10k is your friend

## Node classification

## Useful commands


