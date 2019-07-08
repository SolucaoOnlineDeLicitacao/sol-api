module Call
  module WithExceptionsMethods
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        extend ClassMethods

        def self.call!(*args)
          new(*args).call!
        end

        def call!
          raise call_exception unless call
          true
        end

        def call_exception; raise ImplementThisMethodError end
      end
    end
  end
end
