module Travis
  module Build
    module Shell
      module Filters
        module Logging
          def code
            options[:log] && options[:log_file] ? log(super) : super
          end

          def log(code)
            "#{code} &>> #{options[:log_file]}"
          end
        end

        module Timeout
          def code
            options[:timeout] ? timeout(super) : super
          end

          def timeout(code)
            "tlimit -c #{options[:timeout]} #{code}"
          end
        end

        module Assertion
          def code
            options[:assert] ? assert(super) : super
          end

          def assert(code)
            "#{code}\ntravis_assert"
          end
        end

        module Timing
          def code
            timing = options[:timing]
            echo = options[:echo]
            timing && echo ? measure(super) : super
          end

          def measure(code)
            code = "( time #{code} 2>&3; ) 3>&2 2> /tmp/timing.out"
            "travis_time_start\n#{code}\ntravis_time_finish"
          end
        end

        module Echoize
          def code
            echo = options[:echo]
            echo ? echoize(super, echo.is_a?(String) ? echo : nil) : super
          end

          def echoize(code, echo = nil)
            "echo #{escape("$ #{echo || @code}")}\n#{code}"
          end
        end

        module Retry
          def code
            options[:retry] ? add_retry(super) : super
          end

          def add_retry(code)
            "travis_retry #{code}"
          end
        end
      end
    end
  end
end
