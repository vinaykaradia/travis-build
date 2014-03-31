require 'spec_helper'

describe Travis::Build::Script::Ruby do
  let(:options) { { logs: { build: false, state: false } } }
  let(:data)    { PAYLOADS[:push].deep_clone.merge({ platform: 'windows' }) }

  subject { described_class.new(data, options).compile }

  after :all do
    store_example
  end

  it_behaves_like 'a build script'

  it 'sets TRAVIS_RUBY_VERSION' do
    should set 'TRAVIS_RUBY_VERSION', 'default'
  end

  it 'sets BUNDLE_GEMFILE if a gemfile exists' do
    gemfile 'Gemfile.ci'
    should set 'BUNDLE_GEMFILE', File.join(ENV['PWD'], 'tmp/Gemfile.ci')
  end

  it 'announces ruby --version' do
    should announce 'ruby --version'
  end

  it 'announces bundle --version' do
    should announce 'bundle --version'
  end

  it 'installs with bundle install with the given bundler_args if a gemfile exists' do
    gemfile 'Gemfile.ci'
    should install 'bundle install'
  end

  it 'folds bundle install if a gemfile exists' do
    gemfile 'Gemfile.ci'
    should fold 'bundle install', 'install'
  end

  it "retries bundle install if a Gemfile exists" do
    gemfile "Gemfile.ci"
    should retry_script 'bundle install'
  end

  it 'runs bundle install --deployment if there is a Gemfile.lock' do
    gemfile('Gemfile')
    file('Gemfile.lock')
    should run_script 'bundle install --deployment'
  end

  it 'runs bundle install --deployment if there is a custom Gemfile.ci.lock' do
    gemfile('Gemfile.ci')
    file('Gemfile.ci.lock')
    should run_script 'bundle install --deployment'
  end

  it 'runs bundle exec rake if a gemfile exists' do
    gemfile 'Gemfile.ci'
    should run_script 'bundle exec rake'
  end

  it 'runs rake if a gemfile does not exist' do
    should run_script 'rake'
  end
end
