require "spec"

require "./mock_env"
require "./mock_unix_socket"

require "../src/systemd_notify"

SYSTEMD_SOCKET_MOCK_PATH = "/nonexistent"
SYSTEMD_WATCHDOG_SEC     = 2

describe SystemdNotify do
  context "when started not as a service" do
    describe ".new" do
      it "creates an object" do
        sn = SystemdNotify.new
      end
    end

    describe ".supported?" do
      it "returns false" do
        SystemdNotify.new.supported?.should be_false
      end
    end

    describe ".use_watchdog?" do
      it "returns false" do
        SystemdNotify.new.use_watchdog?.should be_false
      end
    end
  end

  context "when NOTIFY_SOCKET env var contains nonexistent path" do
    describe ".new" do
      it "raises an exception" do
        ENV.mock_env_set("NOTIFY_SOCKET", SYSTEMD_SOCKET_MOCK_PATH)
        expect_raises(Socket::ConnectError, "connect: No such file or directory") do
          SystemdNotify.new
        end
      end
    end
  end

  context "when started as a service Type=notify" do
    ENV.mock_env_set("NOTIFY_SOCKET", SYSTEMD_SOCKET_MOCK_PATH)
    UNIXSocket.mock_path = SYSTEMD_SOCKET_MOCK_PATH
    sn = SystemdNotify.new

    describe ".new" do
      it "creates an object" do
        sn.class.should eq SystemdNotify
      end
    end

    describe ".supported?" do
      it "returns true" do
        sn.supported?.should be_true
      end
    end

    describe ".use_watchdog?" do
      it "returns false" do
        sn.use_watchdog?.should be_false
      end
    end
  end

  context "when started as a service Type=notify and WatchdogSec=#{SYSTEMD_WATCHDOG_SEC}" do
    ENV.mock_env_set("NOTIFY_SOCKET", SYSTEMD_SOCKET_MOCK_PATH)
    ENV.mock_env_set("WATCHDOG_USEC", (SYSTEMD_WATCHDOG_SEC * 1_000_000).to_s)
    UNIXSocket.mock_path = SYSTEMD_SOCKET_MOCK_PATH
    sn = SystemdNotify.new

    describe ".supported?" do
      it "returns true" do
        sn.supported?.should be_true
      end
    end

    describe ".use_watchdog?" do
      it "returns true" do
        sn.use_watchdog?.should be_true
      end
    end
  end
end
