# Profile class used for setting up a Slurm Head node (where the slurmctld daemon runs)
class profiles::slurm::slurmctld {
  # In EL9, the s-nail package replace mailx
  if ( $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '9' ) {
    package { 's-nail':
      ensure => present,
    }
  }
  include slurm::slurmctld
  include profiles::slurm::accounting
}
