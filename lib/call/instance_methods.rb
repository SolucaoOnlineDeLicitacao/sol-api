module Call
  module InstanceMethods
    def initialize(*args)
      return if args.first.blank?

      args.first.each do |param, value|
        instance_variable_set("@#{param}", value)
        self.class.send(:attr_accessor, param)
      end
    end

    def call
      main_method
    end

    def main_method; raise ImplementThisMethodError end
  end
end
