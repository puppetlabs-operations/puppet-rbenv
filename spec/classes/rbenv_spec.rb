require 'spec_helper'

describe 'rbenv', type: 'class' do
  let(:facts) do
    {
      'os' => {
        'family' => 'Debian',
        'distro' => {
          'codename' => 'xenial'
        }
      }
    }
  end
  let(:params) do
    {
      install_dir: '/usr/local/rbenv',
      latest: true,
    }
  end

  it {
    is_expected.to contain_exec('git-clone-rbenv').with(
      'command' => '/usr/bin/git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv',
      'creates' => '/usr/local/rbenv',
    )
  }

  ['plugins', 'shims', 'versions'].each do |dir|
    describe "creates #{dir}" do
      it {
        is_expected.to contain_file("/usr/local/rbenv/#{dir}").with('ensure' => 'directory',
                                                                    'owner'   => 'root',
                                                                    'group'   => 'adm',
                                                                    'mode'    => '0775')
      }
    end
  end

  it {
    is_expected.to contain_file('/etc/profile.d/rbenv.sh').with(
      'ensure' => 'file',
      'mode' => '0775',
    )
  }

  it { is_expected.to contain_exec('update-rbenv') }

  context 'on ubuntu 16.04 - xenial' do
    let(:facts) do
      {
        'os' => {
          'family' => 'Debian',
          'name'   => 'Ubuntu',
          'distro' => {
            'codename' => 'xenial'
          }
        }
      }
    end

    it { is_expected.to contain_package('libgdbm3') }
    it { is_expected.to contain_package('libssl-dev') }
    it { is_expected.to contain_package('libncurses5-dev') }
  end

  context 'on ubuntu 18.04 - bionic' do
    let(:facts) do
      {
        'os' => {
          'family' => 'Debian',
          'name'   => 'Ubuntu',
          'distro' => {
            'codename' => 'bionic'
          }
        }
      }
    end

    it { is_expected.to contain_package('libgdbm5') }
    it { is_expected.to contain_package('libssl1.0-dev') }
    it { is_expected.to contain_package('libncurses5-dev') }
  end

  context 'on ubuntu 22.04 - jammy' do
    let(:facts) do
      {
        'os' => {
          'family' => 'Debian',
          'name'   => 'Ubuntu',
          'distro' => {
            'codename' => 'jammy'
          }
        }
      }
    end

    it { is_expected.to contain_package('libgdbm6') }
    it { is_expected.to contain_package('libssl-dev') }
    it { is_expected.to contain_package('libncurses5-dev') }
  end

  context 'on ubuntu 24.04 - noble' do
    let(:facts) do
      {
        'os' => {
          'family' => 'Debian',
          'name'   => 'Ubuntu',
          'distro' => {
            'codename' => 'noble'
          }
        }
      }
    end

    it { is_expected.to contain_package('libgdbm6t64') }
    it { is_expected.to contain_package('libssl-dev') }
    it { is_expected.to contain_package('libncurses-dev') }
  end
end
