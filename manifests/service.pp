class klbr-puppet::service {
    if $::domain != "vagrant.lan" {
      service { 'puppet':
        ensure  => running,
        enable  => true,
        require => Class["klbr-puppet::install"],
      }
    }
}
