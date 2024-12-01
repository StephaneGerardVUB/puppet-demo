# @summary Set up users
# @param users Hash of users to create
class profiles::users (
  Hash $users,
) {
  $users.each | String $username, Hash $attrs | {
    accounts::user { $username:
      * => $attrs,
    }
  }
}
