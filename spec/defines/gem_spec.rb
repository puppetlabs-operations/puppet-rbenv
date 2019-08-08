require 'spec_helper'

describe 'rbenv::gem' do
  let(:ruby_version) { '2.0.0-p247' }
  let(:facts) { { :osfamily => 'Debian' } }

  describe 'install bundler' do
    let(:title) { 'bundler' }
    let(:gem_version) { '1.3.5' }
    let(:params) do
      {
        :install_dir  => '/usr/local/rbenv',
        :version      => gem_version,
        :ruby_version => ruby_version,
        :env          => ['RUBY_CFLAGS=-O3 -march=native'],
      }
    end

    it { should contain_class('rbenv') }
    it { should contain_exec("gem-install-#{ruby_version}-#{title}-#{gem_version}") }
    it { should contain_exec("rbenv-rehash-#{ruby_version}-#{title}-#{gem_version}") }
    it { should contain_exec("rbenv-permissions-#{ruby_version}-#{title}-#{gem_version}") }

    context 'without docs' do
      let(:params) do
        super().merge({
          :skip_docs => true,
        })
      end

      it do
        should contain_exec("gem-install-#{ruby_version}-#{title}-#{gem_version}").with({
          'command' => /--no-ri --no-rdoc/,
        })
      end

      context 'on ruby >= 2.6.0' do
        let(:ruby_version) { '2.6.3' }

        it do
          should contain_exec("gem-install-#{ruby_version}-#{title}-#{gem_version}").with({
            'command' => /--no-document/,
          })
        end
      end
    end

    context 'with another version of bundler already installed' do
      let(:pre_condition) do
        [
          "rbenv::gem { 'bundler-1.17.3':",
          "  install_dir   => '/usr/local/rbenv',",
          "  version       => '1.17.3',",
          "  ruby_version  => '#{ruby_version}',",
          "  env           => ['RUBY_CFLAGS=-O3 -march=native'],",
          "}",
        ].join("\n")
      end

      it { is_expected.to compile }
    end
  end
end
