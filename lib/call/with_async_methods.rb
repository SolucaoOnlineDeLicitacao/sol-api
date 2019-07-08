module Call
  module WithAsyncMethods
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        extend ClassMethods

        def self.async_call(*args)
          new(*args).async_call
        end

        def async_call
          if call
            async_method
            true
          end
        end

        def async_method; raise ImplementThisMethodError end
      end
    end
  end
end
