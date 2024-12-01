# Set the timezone for all nodes
class profiles::timezone {
  class { 'timezone':
    timezone => 'Etc/UTC',
  }
}
