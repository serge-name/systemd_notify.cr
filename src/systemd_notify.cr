require "socket"

class SystemdNotify
  @socket : UNIXSocket?
  @timeout : Float64?

  def initialize
    @socket = get_socket
    @timeout = get_timeout
  end

  def ready
    return unless supported?

    notify_ready

    if use_watchdog?
      spawn do
        loop do
          notify_watchdog
          wait
        end
      end
    end
  end

  def supported?
    !@socket.nil?
  end

  def use_watchdog?
    !@timeout.nil?
  end

  private def notify_ready
    send_message("READY=1")
  end

  private def notify_watchdog
    send_message("WATCHDOG=1")
  end

  private def get_socket : UNIXSocket?
    begin
      UNIXSocket.new(ENV["NOTIFY_SOCKET"], Socket::Type::DGRAM)
    rescue KeyError
      nil
    end
  end

  # The doc suggest notifying halfway through the timeout
  # https://www.freedesktop.org/software/systemd/man/sd_watchdog_enabled.html
  private def get_timeout : Float64?
    ENV["WATCHDOG_USEC"]?.try { |t|
      t.to_f64 / 1_000_000 / 2
    }
  end

  private def send_message(msg)
    @socket.as(UNIXSocket).puts(msg)
  end

  private def wait
    @timeout.try { |t|
      sleep(t)
    }
  end
end
