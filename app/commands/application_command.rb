class ApplicationCommand

  class << self

    attr_accessor :logger

    def call(*args)
      new(*args).call
    end

    def attributes(*names)
      @attributes ||= []
      return @attributes if names.blank?

      names.each do |name|
        name = name.to_sym
        @attributes << name unless @attributes.include? name

        define_method(name) { attributes[name] }
        define_method("#{name}=") { |value| attributes[name] = value }
      end
    end

    def attribute_names
      @attributes.keys.sort
    end


    def logger
      @logger ||= Rails.logger
    end

  end # class methods

  attr_reader :attributes, :object

  delegate :logger, to: :class


  def initialize(object = nil, **attributes)
    @object = object
    @attributes = attributes

    after_initialize
  end

  def call
    raise NotImplementedError
  end


  private

  # override it for custom behavior
  def after_initialize; end

  #
  # Facilitando o uso de transações - delegando ao ApplicationRecord.
  #
  # :reek:UtilityFunction
  def transaction(*args, &block)
    ApplicationRecord.transaction(*args, &block)
  end
end
