require "spec"

module ENV
  @@mock_env = {} of String => String | Nil

  def self.[](key : String) : String
    @@mock_env[key]? || previous_def
  end

  def self.[]?(key : String) : String | Nil
    @@mock_env[key]? || previous_def
  end

  def self.mock_env_set(key : String, val : String | Nil)
    @@mock_env[key] = val
  end

  def self.mock_env_reset
    @@mock_env = {} of String => String | Nil
  end
end

Spec.before_each do
  ENV.mock_env_reset
end

Spec.after_each do
  ENV.mock_env_reset
end
