# Profile class used for setting up a Slurm Head node (where the slurmctld daemon runs)
class profiles::slurm::slurmctld {
  include slurm::slurmctld
}
