# Profile (base) class used for slurm general settings
class profiles::slurm::common {
  #require ::slurm::params
  include slurm
}
