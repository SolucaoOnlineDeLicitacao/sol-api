module Call
  module Methods
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end
  end
end
