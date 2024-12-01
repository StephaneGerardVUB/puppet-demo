# @summary Manage user privileges
# @param users
#   List of users to allow. This parameter accepts an array of strings representing the usernames that will be granted sudo privileges.
# @example
#   class { 'profiles::sudoers':
#     users
#   }
# @note
#   This class will configure the sudoers file to allow the users in the users array to run commands as root without a password.
#   The default value is [].
#   The secure_path is set to a default value.
#   The sudoers file is configured to allow the users in the users array to run commands as root without a password.
class profiles::sudoers (
  Array[String] $users = [],
) {
  sudo::conf { 'secure_path':
    content  => 'Defaults      secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/puppet/bin"',
    priority => 0,
  }
  $sudoers = lookup('sudoers', Array[String], 'unique', [])
  $sudoers.each | String $user | {
    sudo::conf { $user:
      content  => "${user} ALL=(ALL) NOPASSWD: ALL",
      priority => 10,
    }
  }
}
