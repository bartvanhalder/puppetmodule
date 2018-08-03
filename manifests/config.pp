# This class manages the /etc/puppetlabs/puppet/puppet.conf 
# It can differentiante beteween a a puppet master and puppet agent config
# 
# It uses templates to build the configuration

class puppetmodule::config (
    $master =          $::puppetmodule::master,
    $topleveldomain =  $::puppetmodule::topleveldomain,
    $dns_alt_names =   $::puppetmodule::dns_alt_names,
    $enviornment =     $::puppetmodule::environment,
    $desired_version = $::puppetmodule::desired_version,
){
    if $puppetmodule::puppet_desired_version == 4 or $puppetmodule::puppet_desired_version == 5 {
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
    } else {
        notify {
        'error config':
            name     => 'Config: Unknown Puppet Version',
            message  => 'I don\'t know what you want man, they only told me about Pupper version 4 and 5. What are we using nowadays?',
            withpath => true;
        }
    }

    file { '/etc/puppetlabs/puppet':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
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