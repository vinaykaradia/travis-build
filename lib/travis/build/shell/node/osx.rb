module Travis
  module Build
    module Shell
      class Node
        class Osx < Node; end
      end

      class Cmd < Node
        class Osx < Cmd; end
      end

      class Group < Node
        class Osx < Group
        end
      end

      class Script < Group
        class Osx < Script; end
      end

      class Block < Group
        class Osx < Block; end
      end

      class Conditional < Block
        class Osx < Conditional; end
      end

      class If < Conditional
        class Osx < If; end
      end

      class Elif < Conditional
        class Osx < Elif; end
      end

      class Else < Block
        class Osx < Else; end
      end
    end
  end
end
