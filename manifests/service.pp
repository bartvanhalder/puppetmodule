class klbr_puppetagent::service {
    if $::domain != "vagrant.lan" {
      service { 'puppet':
        ensure  => running,
        enable  => true,
        require => Class["klbr_puppetagent::install"],
      }
    }
}
