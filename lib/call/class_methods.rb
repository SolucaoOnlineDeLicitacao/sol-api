module Call
  module ClassMethods
    def call(*args)
      new(*args).call
    end
  end
end
