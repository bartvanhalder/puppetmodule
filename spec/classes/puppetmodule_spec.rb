require 'spec_helper'

describe 'puppetmodule' do
  let(:title) { 'puppetmodule' }

  # let(:pre_condition) { 'include puppetmodule' }

  # Can not test this as this aren't real class parameters... TODO: fix the code
  # context 'Unsupported version' do
  #   let :params do
  #     { desired_version: '3',}
  #   end
  #   it {
  #     is_expected.to compile.and_raise_error(/I don\'t know what you want man, they only told me about Pupper version 4 and 5. What are we using nowadays?/)
  #   }
  # end

  context 'In all situations' do
    it {
      is_expected.to contain_file('/etc/puppetlabs/puppet').with(
        'ensure' => 'directory',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0755',
      )
      is_expected.to contain_file('/etc/puppetlabs/puppet/puppet.conf').with(
        'ensure' => 'present',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      )
      is_expected.to contain_file('/etc/default/puppet').with(
        'ensure' => 'present',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      )
    }
  end

  it { is_expected.to compile }
  it { is_expected.to compile.with_all_deps }
end
