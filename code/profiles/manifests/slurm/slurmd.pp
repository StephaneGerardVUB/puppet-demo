# Profile class used for setting up a Slurm Compute node
class profiles::slurm::slurmd {
  package { 'dbus-devel':
    ensure => installed,
  }
  slurm::acct::qos { 'qos-interactive':
    ensure   => 'present',
    priority => 20,
    options  => {
      preempt  => 'qos-besteffort',
      grpnodes => 30,
    },
  }

  include slurm::slurmd
}
