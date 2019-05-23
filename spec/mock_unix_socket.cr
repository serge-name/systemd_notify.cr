require "spec"

require "socket"

class UNIXSocket < Socket
  @@mock_path : String | Nil = nil

  def self.mock_path=(value : String | Nil)
    @@mock_path = value
  end

  def self.mock_path_reset
    @@mock_path = nil
  end

  def initialize(@path : String, type : Type = Type::STREAM)
    super(Family::UNIX, type, Protocol::IP)
    if @path == @@mock_path
      File.open("/dev/null")
    else
      previous_def
    end
  end
end

Spec.before_each do
  UNIXSocket.mock_path_reset
end

Spec.after_each do
  UNIXSocket.mock_path_reset
end
