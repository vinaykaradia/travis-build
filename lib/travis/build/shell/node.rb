require 'shellwords'
require 'core_ext/string/indent'
require 'travis/build/shell/node/linux'
require 'travis/build/shell/node/osx'
require 'travis/build/shell/node/windows'
require 'active_support'
require 'active_support/core_ext/module/attribute_accessors'

module Travis
  module Build
    module Shell
      mattr_accessor :platform

      def self.node(name, *args)
        Shell.const_get(platform).const_get(name.to_s.camelize).new(*args)
      end

      module Base
        class Node
          attr_reader :code, :options, :level, :platform

          def initialize(*args)
            @options = args.last.is_a?(Hash) ? args.pop : {}
            @level = options.delete(:level) || 0
            @code = args.first
            @platform = options[:platform]
            yield(self) if block_given?
          end

          def name
            raise "#name has been called"
          end

          def to_s
            code ? code.indent(level) : code
          end

          def escape(code)
            Shellwords.escape(code)
          end
        end

        class Cmd < Node
        end

        class Group < Node
          include Dsl

          attr_reader :nodes

          def initialize(*args, &block)
            @options = args.last.is_a?(Hash) ? args.pop : {}
            @level = options.delete(:level) || 0
            @nodes = []
            @platform = options[:platform]
            args.map { |node| cmd(node, options) }
            yield(self) if block_given?
          end

          def to_s
            nodes.map(&:to_s).join("\n").indent(level)
          end
        end

        class Script < Group
          def to_s
            super + "\n"
          end
        end

        class Block < Group
          attr_reader :open, :close

          def to_s
            [open, super, close].compact.join("\n")
          end

          def script(*args)
            super(*merge_options(args, level: 1))
          end

          def cmd(code, *args)
            super(code, *merge_options(args, level: 1))
          end

          def raw(code, *args)
            super(code, *merge_options(args, level: 1))
          end
        end

        class Conditional < Block
          attr_reader :condition

          def self.create(platform, *args, &block)
            const_get(platform.capitalize).new(*args, &block)
          end

          def initialize(condition, *args, &block)
            args.unshift(args.last.delete(:then)) if args.last.is_a?(Hash) && args.last[:then]
            super(*args, &block)

            @condition = condition

            @open = Node.new("#{name} [[ #{condition} ]]; then", options)
          end
        end

        class If < Conditional
          def close
            Node.new('fi', options)
          end

          def name
            'if'
          end
        end

        class Elif < Conditional
          def name
            'elif'
          end
        end

        class Else < Block
          def open
            @open = Node.new('else', options)
          end

          def name
            'else'
          end
        end
      end
    end
  end
end
