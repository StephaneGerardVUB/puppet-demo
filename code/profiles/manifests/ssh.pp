# Manage sshd config
# Document class parameters
# @param allow_users List of users to allow
# @example
#   class { 'profiles::ssh':
#     allow_users => ['root', 'vagrant'],
#   }
# @note
#   This class will install the openssh-server package, configure the sshd_config file, and start the sshd service.
#   The allow_users parameter is an array of users to allow.
#   The default value is ['root'].
#   The sshd_config file is a template that allows only the users in the allow_users array.
#   The sshd service is restarted when the sshd_config file changes.
class profiles::ssh (
  Array[String] $allow_users = ['root'],
) {
  package { 'openssh-server':
    ensure => latest,
  }

  file { '/etc/ssh/sshd_config':
    content => epp('profiles/ssh/sshd_config.epp', { 'allow_users' => $allow_users, }),
    notify  => Service['sshd'],
  }

  service { 'sshd':
    ensure => running,
    enable => true,
  }
}
