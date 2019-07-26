require 'pathname'

TMP = Pathname.new(__dir__).join('..', '..', 'tmp')
TMP.mkpath
