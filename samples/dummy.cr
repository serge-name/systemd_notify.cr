require "systemd_notify"

spawn do
  loop do
    STDERR.puts Time.now
    STDERR.flush
    sleep(1)
  end
end

sn = SystemdNotify.new.ready

loop do
  # main loop, do nothing
  sleep(10)
end
