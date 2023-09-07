# frozen_string_literal: true

require "pathname"
require "securerandom"
require "fileutils"

module App
  PATH = Pathname(__dir__).join("..", "..", "tmp").freeze
  private_constant :PATH

  def self.create(app)
    root = PATH.join(SecureRandom.uuid).tap(&:mkpath)

    sources = [
      app.join("app"),
      app.join("slices")
    ]

    public_dir = root.join("public")
    assets_dir = public_dir.join("assets")

    Dir.chdir(root) do
      sources.each do |source|
        FileUtils.cp_r(source, root)
      end

      FileUtils.mkdir_p(assets_dir)
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
