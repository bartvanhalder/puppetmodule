# This class manaages all the components of a Puppet installation for server and agents
class puppetmodule (
    $master,
    $topleveldomain,
    $dns_alt_names,
    $environment,
    $desired_version,
) {
    include puppetmodule::install, puppetmodule::config, puppetmodule::service
}
