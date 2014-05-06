module Travis
  module Build
    module Shell
      module Dsl
        module Windows
          include Travis::Build::Shell::Dsl

          def initialize(*args, &block)
            @platform = args.is_a?(Hash) ? args[:platform] : nil
            raise TypeError unless platform == 'windows'
            super
          end

          def set(var, value, options = {})
            command = "$Env:#{var}=@'
#{value}
'@"
            cmd command, options.merge(log: false)
          end

          def echo(string, options = {})
            string.gsub! /\n/, '`n'
            cmd "echo #{escape(string)}", echo: false, log: true
          end

          def cd(path)
            cmd "cd #{path}", echo: true, log: false
          end

          private

            def declare_fold_start(name)
              raw "Write-Host -NoNewLine \"travis_fold:start:#{name}`r\""
            end

            def declare_fold_end(name)
              raw "Write-Host -NoNewLine \"travis_fold:end:#{name}`r\""
            end
        end
      end
    end
  end
end