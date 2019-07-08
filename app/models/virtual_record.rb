#
# Class VirtualRecord provides "record" that are not stored in the database.
#
# You must define its attributes with `attr_accessor` to make VirtualRecord aware of those
# attributes when serializing and validating.
#
#
# inspired by:
#   - https://stackoverflow.com/a/2487338
#   - http://api.rubyonrails.org/v5.0/classes/ActiveModel/Serialization.html
#
class VirtualRecord
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  module Attributable
    extend ActiveSupport::Concern

    class_methods do
      def attributes
        @attributes ||= []
      end

      # overriding to make it "track attributes"
      def attr_accessor(*attrs)
        attributes.concat(attrs)
        super(*attrs)
      end
    end

    def attributes
      self.class.attributes.each_with_object({}) do |attribute, attrs|
        attrs[attribute.to_s] = send(attribute)
      end.with_indifferent_access
    end

    def attributes=(**attrs)
      attrs.each_pair do |name, value|
        send "#{name}=", value
      end
    end
  end
  include Attributable

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def errors_as_json
    # is based on `errors.details` => `{:base=>[{error: :name_or_email_blank}]}`
    # generating simple map => `{ base: :missing }`
    errors.details.each_with_object({}) do |(attr, errs), json|
      # precedence:
      #   - missing
      #   - taken
      #   - invalid
      codes = errs.map { |err| err[:error] }

      json[attr] = if codes.include? :blank
                     :missing
                   elsif codes.include? :taken
                     :taken
                   else
                     :invalid
                   end
    end
  end
end
