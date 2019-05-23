require "socket"

class SystemdNotify
  @socket : UNIXSocket?
  @tmout : Float64?

  def initialize
    @socket = get_socket
    @tmout = get_tmout
  end

  def ready
    send_ready
    if use_watchdog?
      spawn do
        loop do
          watchdog_notify
          wait
        end
      end
    end
  end

  def supported?
    !@socket.nil?
  end

  def send_ready
    send_message("READY=1")
  end

  def use_watchdog?
    !@tmout.nil?
  end

  def watchdog_notify
    if use_watchdog?
      send_message("WATCHDOG=1")
    end
  end

  private def get_socket : UNIXSocket?
    begin
      UNIXSocket.new(ENV["NOTIFY_SOCKET"], Socket::Type::DGRAM)
    rescue KeyError
      nil
    end
  end

  private def get_tmout : Float64?
    ENV["WATCHDOG_USEC"]?.try { |t|
      t.to_f64 / 1_000_000
      # FIXME: check whether timeout is too small
    }
  end

  private def send_message(msg)
    unless @socket.nil?
      @socket.as(UNIXSocket).puts(msg)
    end
  end

  private def wait
    @tmout.try { |t|
      sleep(t)
    }
  end
end