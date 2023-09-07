# frozen_string_literal: true

module Test
  module Sources
    PATH = Pathname(__dir__).join(".", "sources").freeze
    private_constant :PATH

    def self.path(*dir)
      PATH.join(*dir)
    end
  end
end
