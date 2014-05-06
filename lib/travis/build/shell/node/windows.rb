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
        class Windows < Conditional; end
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
        end
      end

      class Else < Block
        class Windows < Else; end
      end
    end
  end
end
