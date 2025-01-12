class Result
  attr_reader :success, :error_message

  def initialize(success, error_message = nil)
    @success = success
    @error_message = error_message
  end

  def self.success
    new(true)
  end

  def self.failure(message)
    new(false, message)
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
