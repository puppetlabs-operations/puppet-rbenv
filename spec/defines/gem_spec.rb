require 'spec_helper'

describe 'rbenv::gem' do
  describe 'install bundler' do
    let(:title) { 'bundler' }
    let(:ruby_version) { '2.0.0-p247' }
    let(:gem_version) { '1.3.5' }
    let(:params) do
      {
        :install_dir  => '/usr/local/rbenv',
        :version      => gem_version,
        :ruby_version => ruby_version,
        :env          => ['RUBY_CFLAGS=-O3 -march=native'],
      }
    end

    let(:facts) { { :osfamily => 'Debian' } }

    it { should contain_class('rbenv') }
    it { should contain_exec("gem-install-#{ruby_version}-#{title}-#{gem_version}") }
    it { should contain_exec("rbenv-rehash-#{ruby_version}-#{title}-#{gem_version}") }
    it { should contain_exec("rbenv-permissions-#{ruby_version}-#{title}-#{gem_version}") }
  end

  context 'with one version of bundler already installed' do
    let(:pre_condition) do
      [
        "rbenv::gem { 'bundler':",
        "  install_dir   => '/usr/local/rbenv',",
        "  version       => '1.3.5',",
        "  ruby_version  => '2.0.0-p247',",
        "  env           => ['RUBY_CFLAGS=-O3 -march=native'],",
        "}",
      ].join("\n")
    end

    let(:title) { 'bundler-1.17.3' }
    let(:ruby_version) { '2.0.0-p247' }
    let(:gem_version) { '1.17.3' }
    let(:params) do
      {
        :install_dir  => '/usr/local/rbenv',
        :version      => gem_version,
        :ruby_version => ruby_version,
        :env          => ['RUBY_CFLAGS=-O3 -march=native'],
      }
    end

    let(:facts) { { :osfamily => 'Debian' } }

    it { is_expected.to compile }
  end
end
