# This class manaages all the components of a Puppet installation
class puppetmodule {
  include puppetmodule::install, puppetmodule::config, puppetmodule::service
}
