# Profile class used for setting up a Slurm Compute node
class profiles::slurm::slurmd {
  package { 'dbus-devel':
    ensure => installed,
  }

  include slurm::slurmd
}
