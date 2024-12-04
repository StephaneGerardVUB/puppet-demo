# Profile class used for setting up a Slurm Head node (where the slurmctld daemon runs)
class profiles::slurm::slurmctld {
  package { 's-nail':
    ensure => present,
  }
  include slurm::slurmctld
}
