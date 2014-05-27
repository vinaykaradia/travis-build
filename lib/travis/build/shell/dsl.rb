require 'travis/build/shell/dsl/linux'
require 'travis/build/shell/dsl/osx'
require 'travis/build/shell/dsl/windows'

module Travis
  module Build
    module Shell
      module Base
        module Dsl
          def initialize(*args, &block)
            @platform = args.is_a?(Hash) ? args[:platform] : nil
            super
          end

          def script(*args, &block)
            nodes << Script.new(*merge_options(args), &block)
            nodes.last
          end

          def cmd(code, *args)
            options = args.last.is_a?(Hash) ? args.last : {}
            node = Cmd.new(code, *merge_options(args))
            options[:fold] ? fold(options[:fold]) { raw(node) } : raw(node)
          end

          def raw(code, *args)
            args = merge_options(args)
            pos = args.last.delete(:pos) || -1
            node = code.is_a?(Node) ? code : Node.new(code, *args)
            nodes.insert(pos, node)
          end

          def set(var, value, options = {})
            command = "export #{var}=#{value}"
            cmd command, options.merge(log: false)
          end

          def echo(string, options = {})
            cmd "echo #{escape(string)}", echo: false, log: true
          end

          def cd(path)
            cmd "cd #{path}", echo: true, log: false
          end

          def if(*args, &block)
            args = merge_options(args)
            els_ = args.last.delete(:else)
            nodes << If.create(platform, *args, &block)
            self.else(els_, args.last) if els_
            nodes.last
          end

          def if_file_exists(*args, &block)
            args_new = args.dup
            args_new[0] = '-f ' + args.first
            self.if(*args_new)
          end

          def elif(*args, &block)
            raise InvalidParent.new(Elif, If, nodes.last.class) unless nodes.last.is_a?(If)
            args = merge_options(args)
            els_ = args.last.delete(:else)
            nodes.last.raw Elif.create(platform, *args, &block)
            self.else(els_, args.last) if els_
            nodes.last
          end

          def elif_file_exists(*args, &block)
            args_new = args.dup
            args_new[0] = '-f ' + args.first
            elif(*args_new)
          end

          def else(*args, &block)
            raise InvalidParent.new(Else, If, nodes.last.class) unless nodes.last.is_a?(If)
            nodes.last.raw Else.new(*merge_options(args), &block)
            nodes.last
          end

          def fold(name, &block)
            declare_fold_start(name)
            result = yield(self)
            declare_fold_end(name)
            result
          end

          private

            def merge_options(args, options = {})
              options = (args.last.is_a?(Hash) ? args.pop : {}).merge(options)
              args << self.options.merge(options)
            end

            def declare_fold_start(name)
              raw "echo -en 'travis_fold:start:#{name}\\r'"
            end

            def declare_fold_end(name)
              raw "echo -en 'travis_fold:end:#{name}\\r'"
            end
        end
      end

      Linux = Base
    end
  end
end
