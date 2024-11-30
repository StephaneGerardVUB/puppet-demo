# Manage sshd config
class profile::ssh (
  Array[String] $allow_users = ['root'],
) {
  package { 'openssh-server':
    ensure => latest,
  }

  file { '/etc/ssh/sshd_config':
    content => epp('profile/ssh/sshd_config.epp', { 'allow_users' => $allow_users, }),
    notify  => Service['sshd'],
  }

  service { 'sshd':
    ensure => running,
    enable => true,
  }
}
