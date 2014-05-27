module Travis
  module Build
    class Script
      module Helpers
        def self.define_instance_methods(platform)
          define_instance_methods_for(Travis::Build::Shell::Dsl)
          define_instance_methods_for(Travis::Build::Shell::Dsl.const_get(platform.capitalize))
        rescue NameError => e
          raise NameError, "Platform #{platform} is not supported."
        end

        def sh
          stack.last
        end

        def failure(message)
          echo message
          raw 'false'
        end

        def stacking
          ->(sh) {
            stack.push(sh)
            yield(sh) if block_given?
            stack.pop
          }
        end

        def announce?(stage)
          stage && stage != :after_result
        end

        private

        def self.define_instance_methods_for(mod)
          mod.instance_methods(false).each do |name|
            define_method(name) do |*args, &block|
              options = args.last if args.last.is_a?(Hash)
              args.last[:timeout] = data.timeouts[options[:timeout]] if options && options.key?(:timeout)
              sh.send(name, *args, &stacking(&block))
            end
          end
        end
      end
    end
  end
end
