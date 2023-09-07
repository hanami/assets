# frozen_string_literal: true

require "pathname"
require "securerandom"
require "fileutils"

module Destination
  PATH = Pathname(__dir__).join("..", "..", "tmp").freeze
  private_constant :PATH

  def self.create
    paths = [
      %w[app assets].join(File::SEPARATOR),
      %w[public assets].join(File::SEPARATOR)
    ]

    root = PATH.join(SecureRandom.uuid).tap(&:mkpath)

    Dir.chdir(root) do
      paths.each do |path|
        FileUtils.mkdir_p(path)
      end
    end

    root
  end

  def self.clean
    return true unless PATH.exist?

    FileUtils.remove_entry_secure(
      PATH
    )
  end
end
