# frozen_string_literal: true

module CI
  def self.enabled?
    ENV["TRAVIS"]
  end
end
