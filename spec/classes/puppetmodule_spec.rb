require 'spec_helper'

describe 'puppetmodule' do
  let(:title) { 'puppetmodule' }

  it { is_expected.to compile }   # this is the simplest test possible to make sure the Puppet code compiles
  # it { is_expected.to compile.with_all_deps }  # same as above except it will test all the dependencies
end