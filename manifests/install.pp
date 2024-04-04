# This class installs the puppet packages
class puppetmodule::install (
    $release_version = $::puppetmodule::release_version,
    $agent_version   = $::puppetmodule::agent_version,
    $server_version  = $::puppetmodule::server_version,
    $db_version      = $::puppetmodule::db_version,
    $major_version   = $::puppetmodule::major_version,
){
  if $major_version == 4 or 5 or 6 or 7 or 8 {
    # Modify path before installing puppet 4
    # Do not lock yourself out of the 'puppet loop'...
    file_line { 'path':
      path  => '/etc/environment',
      line  => 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/puppetlabs/bin"',
      match => '^PATH=".*games"$',
      # The default path on ubuntu ends with /usr/bin/games
      # and does not have the puppet bin dir in it
    }

    # Remove old puppet3-related stuff
    file { '/etc/apt/preferences.d/00-puppet.pref':
      ensure  => absent,
    }
    if $major_version == 4 {

      $repo          = 'PC1'
      $pref_path     = '/etc/apt/preferences.d/00-puppet4.pref'
      $pref_template = 'puppetmodule/00-puppet4.erb'
      $purge_packages = ['puppet5-release', 'puppet6-release']
      $purge_files = [
        '/etc/apt/sources.list.d/pc_repo.list',
        '/etc/apt/preferences.d/00-puppet5.pref',
        '/etc/apt/preferences.d/00-puppet6.pref'
      ]

      package { 'puppetlabs-release-pc1':
        ensure => latest,
      }

    }
    elsif $major_version == 5 {

      $repo          = 'puppet5'
      $pref_path     = '/etc/apt/preferences.d/00-puppet5.pref'
      $pref_template = 'puppetmodule/00-puppet5andup.erb'
      $purge_packages = ['puppetlabs-release-pc1', 'puppet6-release', 'puppet7-release', 'puppet8-release']
      $purge_files = [
        '/etc/apt/sources.list.d/pc_repo.list',
        '/etc/apt/preferences.d/puppetlabs-pc1.list',
        '/etc/apt/preferences.d/00-puppet4.pref',
        '/etc/apt/preferences.d/00-puppet6.pref',
        '/etc/apt/preferences.d/00-puppet7.pref',
        '/etc/apt/preferences.d/00-puppet8.pref'
      ]

    }
    elsif $major_version == 6 {

      $repo          = 'puppet6'
      $pref_path     = '/etc/apt/preferences.d/00-puppet6.pref'
      $pref_template = 'puppetmodule/00-puppet5andup.erb'
      $purge_packages = ['puppetlabs-release-pc1', 'puppet5-release', 'puppet7-release', 'puppet8-release']
      $purge_files = [
        '/etc/apt/sources.list.d/pc_repo.list',
        '/etc/apt/preferences.d/puppetlabs-pc1.list',
        '/etc/apt/preferences.d/00-puppet4.pref',
        '/etc/apt/preferences.d/00-puppet5.pref',
        '/etc/apt/preferences.d/00-puppet7.pref',
        '/etc/apt/preferences.d/00-puppet8.pref'
      ]
    }
    elsif $major_version == 7 {

      $repo          = 'puppet7'
      $pref_path     = '/etc/apt/preferences.d/00-puppet7.pref'
      $pref_template = 'puppetmodule/00-puppet5andup.erb'
      $purge_packages = ['puppetlabs-release-pc1', 'puppet5-release', 'puppet6-release', 'puppet8-release']
      $purge_files = [
        '/etc/apt/sources.list.d/pc_repo.list',
        '/etc/apt/preferences.d/puppetlabs-pc1.list',
        '/etc/apt/preferences.d/00-puppet4.pref',
        '/etc/apt/preferences.d/00-puppet5.pref',
        '/etc/apt/preferences.d/00-puppet6.pref',
        '/etc/apt/preferences.d/00-puppet8.pref'
      ]
    }
    elsif $major_version == 8 {

      $repo          = 'puppet8'
      $pref_path     = '/etc/apt/preferences.d/00-puppet8.pref'
      $pref_template = 'puppetmodule/00-puppet5andup.erb'
      $purge_packages = ['puppetlabs-release-pc1', 'puppet5-release', 'puppet6-release', 'puppet7-release']
      $purge_files = [
        '/etc/apt/sources.list.d/pc_repo.list',
        '/etc/apt/preferences.d/puppetlabs-pc1.list',
        '/etc/apt/preferences.d/00-puppet4.pref',
        '/etc/apt/preferences.d/00-puppet5.pref',
        '/etc/apt/preferences.d/00-puppet6.pref',
        '/etc/apt/preferences.d/00-puppet7.pref',

      ]
    }

    # End of Puppet version selection statements

    $purge_packages.each | String $purge_package | {
      package { $purge_package:
        ensure => purged,
      }
    }

    $purge_files.each | String $purge_file | {
      file { $purge_file:
        ensure => absent,
        force  => true,
      }
    }

    if $major_version < 7 {
      apt::source { 'puppetlabs':
        location => 'http://apt.puppetlabs.com',
        repos    => $repo,
        include  => {
          'deb' => true,
        },
        key      => {
          'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
          'server' => 'pgp.mit.edu',
        },
      }
    } else {
      apt::source { 'puppetlabs':
        location => 'http://apt.puppetlabs.com',
        repos    => $repo,
        include  => {
          'deb' => true,
        },
        key      => {
          'id'     => 'D6811ED3ADEEB8441AF5AA8F4528B6CD9E61EF26',
          'server' => 'pgp.mit.edu',
        },
      }
    }

    # check if any apt preferences are given
    if  $release_version == '' and $agent_version == '' and  $server_version == '' {
      $ensure_apt_prefs = absent
    }    else {
      $ensure_apt_prefs = present
    }

    file { 'puppet apt preferences':
        ensure  => $ensure_apt_prefs,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        path    => $pref_path,
        content => template($pref_template),
        notify  => Class[puppetmodule::service],
        force   => true,
    }


    package { 'puppet-agent':
        ensure => latest,
    }

    # if we have a puppet master on our hands, install the puppetserver
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
