# Set up users
# Document class
# @param [Hash] $users Hash of users to create
class profile::users (
  Hash $users,
) {
  $users.each | String $username, Hash $attrs | {
    accounts::user { $username:
      * => $attrs,
    }
  }
}
