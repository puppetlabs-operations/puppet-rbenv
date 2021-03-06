# == Define: rbenv::gem
#
# Calling this define will install a ruby gem for a specific ruby version
#
# === Variable
#
# [$install_dir]
#   This is set when you declare the rbenv class. There is no
#   need to overrite it when calling the rbenv::gem define.
#   Default: $rbenv::install_dir
#   This variable is required.
#
# [$gem]
#   The name of the gem to be installed. Useful if you are going
#   to install the same gem under multiple ruby versions.
#   Default: $title
#   This variable is optional.
#
# [$version]
#   The version of the gem to be installed.
#   Default: '>= 0'
#   This variable is optional.
#
# [$ruby_version]
#   The ruby version under which the gem will be installed.
#   Default: undefined
#   This variable is required.
#
# [$skip_docs]
#   Skips the installation of ri and rdoc docs.
#   Default: false
#   This variable is optional.

# [$timeout]
#   Seconds that a gem has to finish installing. Set to 0 for unlimited.
#   Default: 300
#   This variable is optional.
#
# [$env]
#   This is used to set environment variables when installing a gem.
#   Default: []
#   This variable is optional.
#
# === Examples
#
# rbenv::gem { 'thor': ruby_version => '2.0.0-p247' }
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
define rbenv::gem(
  $install_dir  = $rbenv::install_dir,
  $gem          = $title,
  $version      = '>=0',
  $ruby_version = undef,
  $skip_docs    = false,
  $timeout      = 300,
  $env          = $rbenv::env,
) {
  include rbenv

  if $ruby_version == undef {
    fail('You must declare a ruby_version for rbenv::gem')
  }

  if ($skip_docs) {
    if ($ruby_version =~ /^1\./) or ($ruby_version =~ /^2\.[0-5]\./) {
      # Use the old-style no docs flags on Ruby < 2.6.0
      $docs = '--no-ri --no-rdoc'
    } else {
      # Ruby 2.6.0 and beyond need to new-style no docs flag
      $docs = '--no-document'
    }
  } else {
    $docs = ''
  }

  $environment_for_install = concat(["RBENV_ROOT=${install_dir}"], $env)

  exec { "gem-install-${ruby_version}-${gem}-${version}":
    command => "gem install ${gem} --version '${version}' ${docs}",
    unless  => "gem list ${gem} --installed --version '${version}'",
    path    => [
      "${install_dir}/versions/${ruby_version}/bin/",
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin'
    ],
    timeout => $timeout
  }~>
  exec { "rbenv-rehash-${ruby_version}-${gem}-${version}":
    command     => "${install_dir}/bin/rbenv rehash",
    refreshonly => true,
  }~>
  exec { "rbenv-permissions-${ruby_version}-${gem}-${version}":
    command     => "/bin/chown -R ${rbenv::owner}:${rbenv::group} \
                  ${install_dir}/versions/${ruby_version}/lib/ruby/gems && \
                  /bin/chmod -R g+w \
                  ${install_dir}/versions/${ruby_version}/lib/ruby/gems",
    refreshonly => true,
  }

  Exec {
    environment => $environment_for_install,
    require => Exec["rbenv-install-${ruby_version}"]
  }
}
