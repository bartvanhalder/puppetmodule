require 'spec_helper'

describe 'puppetmodule' do
  let(:title) { 'puppetmodule' }

  context 'In all situations' do
    it {
      is_expected.to contain_file('/etc/puppetlabs/puppet').with(
        'ensure' => 'directory',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0755',
      )
      is_expected.to contain_file('/etc/default/puppet').with(
        'ensure' => 'present',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      )
    }
  end

  # context 'unsupported version' do
  #   let :params do
  #     { desired_version: '3' }
  #   end

  #   it { is_expected.to compile.and_raise_error(%r{Unsupported puppet version}) }
  # end

  # context 'supported version' do
  #   let(:params) do
  #     { desired_version: '4' }
  #   end

  #   it {
  #     is_expected.to compile
  #     is_expected.to contain_file('/etc/puppetlabs/puppet/puppet.conf').with(
  #       'ensure' => 'present',
  #       'owner'  => 'root',
  #       'group'  => 'root',
  #       'mode'   => '0644',
  #     )
  #   }
  # end

  it { is_expected.to compile }
  it { is_expected.to compile.with_all_deps }
end
