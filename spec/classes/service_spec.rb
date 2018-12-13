require 'spec_helper'

describe 'puppetmodule::service', type: :class do
  let :pre_condition do
    'include puppetmodule'
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with all defaults' do
        it { is_expected.to compile }
      end
    end
  end
end
