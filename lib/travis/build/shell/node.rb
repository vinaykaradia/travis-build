require 'shellwords'
require 'core_ext/string/indent'
require 'travis/build/shell/node/linux'
require 'travis/build/shell/node/osx'
require 'travis/build/shell/node/windows'

module Travis
  module Build
    module Shell
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
          self.class.name.split('::').last.downcase
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
        POWERSHELL_OP = {
          '=' => '-eq',
          '!=' => '-ne'
        }

        attr_reader :condition

        def initialize(condition, *args, &block)
          args.unshift(args.last.delete(:then)) if args.last.is_a?(Hash) && args.last[:then]
          super(*args, &block)

          @condition = condition

          case platform
          when 'windows'
            @open = Node.new("#{name} ( #{powershell_cond(condition)} ) {", options)
          else
            @open = Node.new("#{name} [[ #{condition} ]]; then", options)
          end
        end

        private
        def powershell_cond(condition)
          cond = condition.strip
          case cond
          when /\A(!?)\s*\-([a-zA-Z])\s*(\S+)\z/
            cond = "#{$1}(Test-Path #{$3})"
          when /\A(\S+)\s*(=|!=)\s*(\S+)\z/
            cond = POWERSHELL_OP.has_key?($2) ? "#{$1} #{POWERSHELL_OP[$2]} #{$3}" : cond
          else
            cond
          end
        end
      end

      class If < Conditional
        def self.create(platform, *args, &block)
          const_get(platform.capitalize).new(*args, &block)
        end

        def close
          Node.new('fi', options)
        end
      end

      class Elif < Conditional
        def open
          case platform
          when 'windows'
            @open = Node.new("} elseif ( #{powershell_cond(condition)} ) {", options)
          else
            super
          end
        end
      end

      class Else < Block
        def open
          case platform
          when 'windows'
            @open = Node.new('} else {', options)
          else
            @open = Node.new('else', options)
          end
        end
      end
    end
  end
end
