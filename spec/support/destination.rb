# frozen_string_literal: true

require "pathname"
require "securerandom"
require "fileutils"

module Destination
  PATH = Pathname(__dir__).join("..", "..", "tmp").freeze
  private_constant :PATH

  def self.create
    PATH.join(SecureRandom.uuid).tap(&:mkpath)
  end

  def self.clean
    return true unless PATH.exist?

    FileUtils.remove_entry_secure(
      PATH
    )
  end
end
