require 'spec_helper'

describe 'puppetmodule' do
  let(:title) { 'puppetmodule' }

  it { is_expected.to compile }
  it { is_expected.to compile.with_all_deps }
end
