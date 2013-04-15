class etckeeper (
    $ensure='running',
    $enable=true,
    $autoupdate=false
) {

    if $autoupdate == true {
        $package_ensure = latest
    } elsif $autoupdate == false {
        $package_ensure = present
    } else {
        fail('autoupdate parameter must be true or false')
    }

    case $::osfamily {
        Debian: {
            $highlevel_package_manager  = 'apt'
            $lowlevel_package_manager   = 'dpkg'
            $hgpackage                  = 'mercurial'
            $etckepeer_conf             = '/etc/etckeeper/etckeeper.conf'
            $package_name               = [ 'etckeeper' ]
        }
        RedHat: {
            $highlevel_package_manager  = 'yum'
            $lowlevel_package_manager   = 'rpm'
            $hgpackage                  = 'mercurial'
            $etckepeer_conf             = '/etc/etckeeper/etckeeper.conf'
            $package_name               = [ 'etckeeper' ]
        }
        default: {
            fail("The ${module_name} module is not supported on ${::osfamily} based systems")
        }
    }
    
    if !defined(Package[$hgpackage]) {
        package { $hgpackage: }
    }
    
    package { 'etckeeper':
        ensure  => $package_ensure,
        name    => $package_name,
    }
    
    file { $etckepeer_conf:
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('etckeeper/etckeeper.conf.erb'),
        require => Package[$package_name],
    }
    
    exec { 'etckeeper-init':
        command => 'etckeeper init',
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        cwd     => '/etc',
        creates => '/etc/.hg',
        require => [ Package[$hgpackage], Package[$package_name], ],
    }
}