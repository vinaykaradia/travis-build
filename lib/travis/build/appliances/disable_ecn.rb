require 'travis/build/appliances/base'

module Travis
  module Build
    module Appliances
      class DisableEcn < Base
        CMD = 'echo 2 | sudo tee /proc/sys/net/ipv4/tcp_ecn'

        def apply
          sh.cmd CMD
        end

        def apply?
          data.disable_ecn?
        end
      end
    end
  end
end
