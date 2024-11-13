# puppet-demo
Typical small and simple Puppet workspace to use for demonstrations or as a starting point for real use case

## Usage

Git clone this repo on the machine where you want to create an instance of puppetserver.
Adapt and run pm_install.sh to install a new puppet server.

Once the server is set up, you still have two steps to get your machines under control of Puppet:
- set up of the bootstrapping for the automatic enrollement of machines;
- to implement a solution to classify your machines.

It is natural to achieve these 2 steps with the help of the provisioning system (Foreman or Quattor or...).

## Bootstrapping for automatic enrollement

- Installation of the agent
- Configuration of the agen

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


