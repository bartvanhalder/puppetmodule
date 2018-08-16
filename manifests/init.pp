# This class manaages all the components of a Puppet installation for server and agents
class puppetmodule (
    $master,
    $topleveldomain,
    $dns_alt_names,
    $environment,
    $desired_version,
    $puppetdb,
) {
    include puppetmodule::install
    include puppetmodule::config
    include puppetmodule::service
}
