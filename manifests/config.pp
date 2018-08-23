# This class manages the /etc/puppetlabs/puppet/puppet.conf 
# It can differentiante beteween a a puppet master and puppet agent config
# 
# It uses templates to build the configuration

class puppetmodule::config (
    # these are available in the main class scope 
    # this class uses them to fill in the templates for the puppet.conf
    $master =          $::puppetmodule::master,
    $topleveldomain =  $::puppetmodule::topleveldomain,
    $dns_alt_names =   $::puppetmodule::dns_alt_names,
    $environment =     $::puppetmodule::environment,
    $major_version =   $::puppetmodule::major_version,
    $puppetdb =        $::puppetmodule::puppetdb,
){
    if $puppetmodule::major_version == 4 or $puppetmodule::major_version == 5 {
        if $master == true {
            # we only need to use these variables if we're provisioning a puppetmaster
            $template       = 'puppetmodule/master.erb'
            exec { 'set permissions on puppet code directory for the puppet user':
                command => '/usr/bin/setfacl -Rdm u:puppet:r-X /etc/puppetlabs/code',
                unless  => '/usr/bin/getfacl /etc/puppetlabs/code | grep -q "default:user:puppet:r-x"',
                require => [
                    Package['acl'],
                ],
            }
        } else {
            # if we are not a puppet master, select the client template
            $template       = 'puppetmodule/client.erb'
        }
        file { '/etc/puppetlabs/puppet/puppet.conf':
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => template($template), # as defined above
            require => Class[puppetmodule::install],
            notify  => Class[puppetmodule::service],
        }
    } else {
        notify {
        'error config':
            name     => 'Config: Unknown Puppet Version',
            message  => 'Unsupported puppet version',
            withpath => true;
        }
    }

    file { '/etc/puppetlabs/puppet':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { '/etc/default/puppet':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/puppetmodule/defaults',
        require => Class[puppetmodule::install],
        notify  => Class[puppetmodule::service],
    }
}