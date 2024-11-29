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

All resource declarations follow the same general pattern:

```
RESOURCE_TYPE { TITLE:
  ATTRIBUTE => VALUE,
  ...
}
```

The main builtin resource types available natively are: file, package, service, user, cron, exec.

Many resource types have an **ensure** attribute that can take different values according to the type.

Resource types can be extended, you can create your own, but that's another long story...


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

## Coding examples

### Packages

* Declaring a package:

  ```
  package { 'openssl':
    ensure => installed,
  }
  ```

* Removing a package:

  ```
  package { 'apparmor':
    ensure => absent,
  }
  ```

* Installing a well defined release of a package:

  ```
  package { 'openssl':
    ensure => '1.0.2g-1ubuntu4.8',
  }
  ```
* Installing a Ruby gem:

  ```
  package { 'puppet-lint':
    ensure => installed,
    provider => gem,
  }
  ```

  It's worth mentionning here that 'pip', 'pip2' and 'pip3' providers are also available.

* Installing a list of packages:

  ```
  $packagestoinstall = ['vim', 'nano', 'git']
  package { $packagestoinstall:
    ensure => installed,
  }
  ```

### Files

* File with content

  ```
  file { '/tmp/hello.txt':
    content => "hello, world\n",
  }
  ```

* File with content from a source file

  ```
  file { '/etc/motd':
    source => 'puppet://modules/examples/files/motd.txt',
  }
  ```

  This example suppose that the 'examples' module contains a directory 'files' with the file 'motd.txt' in it.

* File with ownership and permissions

  ```
  file { '/tmp/hello.txt':
    ensure => present,
    owner => 'toto',
    group => 'toto',
    mode => '0644',
  }
  ```

* Directory

  ```
  file { '/etc/myappconfdir':
    ensure => directory,
  }

  ```

* Symlink

  ```
  file { '/etc/mylink':
    ensure => link,
    target => '/etc/motd',
  }
  ```

### Services

* Enable a service and make sure it is running

  ```
  service { 'ntp':
    ensure => running,
    enable => true,
  }
  ```

### Users

* Create a group and a user in this group

  ```
  group { 'devops':
    ensure => present,
    gid => '3000',
  }

  user { 'steph':
    ensure => present,
    uid => '3001',
    home => '/home/steph',
    shell => '/bin/bash',
    groups => ['devops'],
  }
  ```

* Removing a user

  ```
  user { 'toto':
    ensure => absent,
  }
  ```

### Cron

### Exec

### Links between resources

## Hiera




## Integration with Git

r10k is your friend

## Node classification

In the Puppet terminology, to classify a node means to determine:
- the classes to include to the node;
- the value of parameters to pass to the included parametrized classes;
- the environment of the node.

The most basic method to classify nodes is to use node definitions in the site.pp file like in this example:

```
node 'www1.example.com' {
  include common
  include apache
  include squid
}
node 'db1.example.com' {
  include common
  include mysql
}
```

However, this approach based on the machine names might be too limited to manage large and/or complex sites.

You can also classify nodes using an external node classifier (ENC), which is a script or an application that tells Puppet which classes to include to a node. The ENC can replace or work in concert with the node definitions of the main manifest (site.pp). An ENC takes as only argument the name of the node, and it returns a yaml document describing the node as in the main manifest. You can write your own ENC, or you can use the ENC functionality embedded in Foreman, or in Puppet Enterprise or in the Puppet Community Dashboard...

There is a third very flexible approach that consists in using facts in conjunction with Hiera. That's the approach we are using in this workspace.

## Useful commands

### On the node

puppet agent -t --logdest console

puppet resource package
puppet resource user

### On the Puppet server

r10k deploy environment -p production

puppet generate types --verbose --debug --environment production

puppet module list --environment production

