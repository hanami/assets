# frozen_string_literal: true

require "rspec"
require "hanami/assets"
require "pathname"

SPEC_ROOT = Pathname(__FILE__).dirname

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.after(:suite) do
    Destination.clean
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus
  config.disable_monkey_patching!

  config.warnings = true

  config.default_formatter = "doc" if config.files_to_run.one?

  config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed
end

Dir.glob(File.join(Dir.pwd, "spec", "support", "*.rb"), &method(:require))
