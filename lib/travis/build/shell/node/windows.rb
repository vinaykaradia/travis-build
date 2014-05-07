module Travis
  module Build
    module Shell
      class Node
        class Windows < Node; end
      end

      class Cmd < Node
        class Windows < Cmd; end
      end

      class Group < Node
        class Windows < Group
        end
      end

      class Script < Group
        class Windows < Script; end
      end

      class Block < Group
        class Windows < Block; end
      end

      class Conditional < Block
        class Windows < Conditional
          POWERSHELL_OP = {
            '=' => '-eq',
            '!=' => '-ne'
          }

          def initialize(condition, *args, &block)
            args.unshift(args.last.delete(:then)) if args.last.is_a?(Hash) && args.last[:then]
            super(*args, &block)

            @condition = condition

            @open = Node.new("#{name} ( #{powershell_cond(condition)} ) {", options)
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
      end

      class If < Conditional
        class Windows < If
          def close
            Node.new('}', options)
          end
        end
      end

      class Elif < Conditional
        class Windows < Elif
          def name
            'elseif'
          end

          def open
            @open = Node.new("} elseif ( #{powershell_cond(condition)} ) {", options)
          end
        end
      end

      class Else < Block
        class Windows < Else
          def open
            @open = Node.new('} else {', options)
          end
        end
      end
    end
  end
end
