# frozen_string_literal: true

require "pathname"

# TMP = Pathname.new(__dir__).join("..", "tmp")
TMP = Pathname.new(__dir__).join("..", "..", "tmp")
TMP.mkpath
