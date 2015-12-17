# Babel support is in Tilt (master), but not released yet.
#
# Require this file ONLY if you need to transpile ES6 assets.
begin
  require 'tilt'
  require 'tilt/template'
  require 'babel/transpiler'
rescue LoadError
  puts "Please install `babel-transpiler' gem"
  exit 1
end

unless defined?(Tilt::BabelTemplate)
  module Tilt
    class BabelTemplate < Template
      def prepare
        options[:filename] ||= file
      end

      def evaluate(scope, locals, &block)
        @output ||= Babel::Transpiler.transform(data)["code"]
      end
    end
  end

  Tilt.register(Tilt::BabelTemplate, 'babel')
  Tilt.register(Tilt::BabelTemplate, 'es6')
  Tilt.register(Tilt::BabelTemplate, 'jsx')
end
