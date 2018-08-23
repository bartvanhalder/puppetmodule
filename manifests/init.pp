# This class manaages all the components of a Puppet installation for server and agents
class puppetmodule (
    $master,
    $topleveldomain,
    $dns_alt_names,
    $environment,
    $major_version,
    $puppetdb,
    $release_version,
    $agent_version,
    $server_version,
) {
    include puppetmodule::install
    include puppetmodule::config
    include puppetmodule::service
}
