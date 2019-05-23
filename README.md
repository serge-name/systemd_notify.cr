# systemd_notify.cr

Sends startup and periodical notifications to systemd

# How to use

```crystal
require "systemd_notify"

SystemdNotify.new.ready
```

This code sends a startup notification to systemd. If a watchdog
has been enabled it also starts a separate fiber that sends
periodical messages to systemd.
