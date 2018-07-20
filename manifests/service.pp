# This class manages the puppet service
class puppetmodule::service {
    if $::domain != vagrant.lan {
      service { 'puppet':
        ensure  => running,
        enable  => true,
        require => Class[puppetmodule::install],
      }
    }
}
