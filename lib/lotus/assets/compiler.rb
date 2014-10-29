module Lotus
  module Assets
    class Compiler
      def self.compile(configuration, type, source)
        # FIXME return unless configuration.compile
        require 'tilt'
        definition = configuration.asset(type)

        if s = definition.find(source)
          dest = configuration.destination.join(definition.relative_path(source))
          dest.dirname.mkpath

          # TODO File::WRONLY|File::CREAT
          dest.open('w') {|f| f.write Tilt.new(s).render }
        end
      end
    end
  end
end
