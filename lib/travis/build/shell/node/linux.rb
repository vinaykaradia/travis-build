module Travis
  module Build
    module Shell
      class Node
        class Linux < Node; end
      end

      class Cmd < Node
        class Linux < Cmd; end
      end

      class Group < Node
        class Linux < Group
        end
      end

      class Script < Group
        class Linux < Script; end
      end

      class Block < Group
        class Linux < Block; end
      end

      class Conditional < Block
        class Linux < Conditional; end
      end

      class If < Conditional
        class Linux < If; end
      end

      class Elif < Conditional
        class Linux < Elif; end
      end

      class Else < Block
        class Linux < Else; end
      end
    end
  end
end
