# This class installs the puppet packages
class puppetmodule::install (
    $release_version = $::puppetmodule::release_version,
    $agent_version =   $::puppetmodule::agent_version,
    $server_version =  $::puppetmodule::server_version,
){
  if $puppetmodule::major_version == 4 or $puppetmodule::major_version == 5 {
    # modify path before installing puppet 4
    # do not lock yourself out of the 'puppet loop'...
    file_line { 'path':
      path  => '/etc/environment',
      line  => 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/puppetlabs/bin"',
      match => '^PATH=".*games"$',
      # The default path ends with /usr/bin/games and does not have the puppet bin dir in it
    }

    # remove old stuff
    file { '/etc/apt/preferences.d/00-puppet.pref':
      ensure  => absent,
    }
    if $puppetmodule::major_version == 4 {
      apt::source { 'puppetlabs-pc1':
        location => 'http://apt.puppetlabs.com',
        repos    => 'PC1',
        include  => {
          'deb' => true,
        },
        key      => {
          'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
          'server' => 'pgp.mit.edu',
        },
      }

      file { '/etc/apt/preferences.d/00-puppet4.pref':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('puppetmodule/00-puppet4.erb'),
        notify  => Class[puppetmodule::service],
      }
      # remove double puppet apt repo
      file { '/etc/apt/sources.list.d/pc_repo.list':
        ensure  => absent,
      }
      $puppet_client_packages = ['puppet-agent', 'puppetlabs-release-pc1']
      package { $puppet_client_packages:
        ensure => latest,
      }
      package { 'puppet5-release':
        ensure => purged,
      }
      file { '/etc/apt/preferences.d/00-puppet5.pref':
        ensure  => absent,
      }
    }
    elsif $puppetmodule::major_version == 5 {
      file { '/etc/apt/preferences.d/00-puppet5.pref':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('puppetmodule/00-puppet5.erb'),
        notify  => Class[puppetmodule::service],
      }
      file { '/etc/apt/preferences.d/00-puppet4.pref':
        ensure  => absent,
      }
      file { '/etc/apt/sources.list.d/puppetlabs-pc1.list':
        ensure => absent,
      }
      package { 'puppetlabs-release-pc1':
        ensure => purged,
      }
      # nu moeten we nog puppet5 repo installeren en package regelen

      apt::source { 'puppetlabs':
        location => 'http://apt.puppetlabs.com',
        repos    => 'puppet5',
        include  => {
          'deb' => true,
        },
        key      => {
          'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
          'server' => 'pgp.mit.edu',
        },
      }

      package { 'puppet-agent':
          ensure => latest,
      }

      # we don't remove the old packages, they use the same init files and such
    }
    elsif $puppetmodule::major_version == 6 {
      file { '/etc/apt/preferences.d/00-puppet6.pref':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('puppetmodule/00-puppet6.erb'),
        notify  => Class[puppetmodule::service],
      }
      file { '/etc/apt/preferences.d/00-puppet4.pref':
        ensure  => absent,
      }
      file { '/etc/apt/preferences.d/00-puppet5.pref':
        ensure  => absent,
      }
      file { '/etc/apt/sources.list.d/puppetlabs-pc1.list':
        ensure => absent,
      }
      package { 'puppetlabs-release-pc1':
        ensure => purged,
      }
      # nu moeten we nog puppet5 repo installeren en package regelen

      apt::source { 'puppetlabs':
        location => 'http://apt.puppetlabs.com',
        repos    => 'puppet6',
        include  => {
          'deb' => true,
        },
        key      => {
          'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
          'server' => 'pgp.mit.edu',
        },
      }

      package { 'puppet-agent':
          ensure => latest,
      }

      # we don't remove the old packages, they use the same init files and such
    }

    # EINDE van de PUPPET 4/5/6 selectie statements

    # if we have a puppet4 master on our hands, install the puppetserver
    if $puppetmodule::master == true {
      package { 'puppetserver':
              ensure => latest,
      }
    }
  }
  else {
    notify {
        'error install':
            name     => 'Install: Unknown Puppet Version',
            message  => 'Unsupported puppet version',
            withpath => true;
    }
  }
}
