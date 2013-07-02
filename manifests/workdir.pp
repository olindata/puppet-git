# From http://reductivelabs.com/trac/puppet/wiki/Recipes/SubversionWorkingCopy
# Example usage: (https://reductivelabs.com/svn/vault into /var/svn/vault.cache)
#   git::workdir { vault:
#       repository => "https://user:password@reductivelabs.com/git/vault",
#       local_container => "/var/svn",
#       local_name => "vault.cache",
#       branch => "somebranch",
#   }
#
# Note, make sure you manage file["$local_container"] somewhere else, as it's required.
# Note2, you may want to modify the require lines for your package provider for subversion

define git::workdir($repository, $local_container, $local_name = false, $post_checkout_script = undef, $post_update_script = undef, $runas_user = 'root', $runas_group = 'root', $branch = 'master')
{
    include git

    $owner_real = $owner ? { false => 0, default => $owner }
    $group_real = $group ? { false => 0, default => $group }
    $local_name_real = $local_name ? { false => $name, default => $local_name }

    Exec {
        path  => '/usr/bin:/bin:/opt/local/bin:/usr/local/bin',
        user  => $runas_user,
        group => $runas_group,
    }
  
    exec { "git-clone-${name}":
        command => "git clone --branch ${branch} ${repository} ${local_name_real}",
        cwd     => $local_container,
        require => [ File[$local_container], Package['git-core']],
        creates => "${local_container}/${local_name_real}/.git",
    }

    exec { "git-pull-${name}":
        command => 'git pull',
        cwd     => "${local_container}/${local_name_real}",
        require => Exec["git-clone-${name}"],
    }

}
