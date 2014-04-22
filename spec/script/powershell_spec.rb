require 'spec_helper'

describe Travis::Build::Script::Ruby do
  let(:options) { { logs: { build: false, state: false } } }
  let(:data)    { PAYLOADS[:push].deep_clone.merge({ platform: 'windows' }) }

  subject { described_class.new(data, options).compile }

  after :all do
    store_example
  end

  # it_behaves_like 'a build script'

end
