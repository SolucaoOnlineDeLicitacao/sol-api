class ApplicationRecord < ActiveRecord::Base
  include Versionable

  self.abstract_class = true

  class << self
    def human_enum_name(name, value)
      I18n.t("activerecord.enums.#{model_name.singular}.#{name}.#{value}")
    end
  end

  def human_enum_name(name)
    value = send(name)
    self.class.human_enum_name(name, value)
  end

  #
  #   Gera um mapa de <atributo,código_de_erro>, sem se preocupar com i18n, para
  # que seja usado em retornos de endpoints da API JSON. Assim, o client fica
  # responsável por entender o 'código de erro' e traduzir para sua língua.
  #
  #   Ainda, "simplifica" os códigos de erro para 3:
  #   - :missing - validação de presença   (:blank no ActiveRecord)
  #   - :taken   - validação de unicidade  (:taken no ActiveRecord)
  #   - :invalid - demais validações (formato, tipo de dado, ...)
  #
  # Uso:
  # ```ruby
  # # Controlador para Usuários
  # class UsersController < ...
  #   def create
  #     if user.save
  #       render json: user
  #     else
  #       render status: :unprocessable_entity,
  #              json: {
  #                message: t('.failure'),
  #                errors: user.errors_as_json
  #              }
  #     end
  #   end
  # end
  # ```
  #
  # :reek:FeatureEnvy
  # :reek:NestedIterators
  def errors_as_json
    # baseia-se em `errors.details` => `{:base=>[{error: :name_or_email_blank}]}`
    # gerando mapa simples => `{ base: :missing }`
    errors.details.each_with_object({}) do |(attr, errs), json|
      # precedência:
      #   - missing
      #   - taken
      #   - invalid
      codes = errs.map { |err| err[:error] }

      json[attr] = if codes.include? :blank
                     :missing
                   elsif codes.include? :taken
                     :taken
                   elsif codes.include? :too_many
                     :too_many
                   elsif codes.include? :different
                     :different
                   else # if codes.any? { |code| code != :blank }
                     :invalid
                   end
    end
  end

  #
  # Cria uma instância decorada de um registro ActiveRecord, usando o ApplicationDecorator.
  #
  def decorate(with: nil)
    decorator_class = with || "#{self.class.name}Decorator".constantize

    decorator_class.new self
  end


  #
  # Serializa instâncias de ActiveRecord usando FastJsonapi, retornando
  # uma "serialização" JSON - uma String Ruby representando o JSON.
  #
  # uso:
  # ```ruby
  # property = Property.new(**attrs)
  # serialized_property = property.serialize
  # serialized_property_collection = property.serialize with: Collections::PropertySerializer
  #
  # # controller
  # render json: serialized_property
  # render json: serialized_property_collection
  # ```
  #
  # Para recuperar uma Hash, faça:
  # ```ruby
  # hash = property.serialize as: :hash
  # ```
  #
  def serialize(with: nil, as: :json, **options)
    serializer_class = with || "#{self.class.name}Serializer".constantize
    serializer = serializer_class.new(self, options)

    case as
    when :hash then serializer.serializable_hash
    # default json
    # when :json then serializer.serialized_json
    else serializer.serialized_json
    end
  end
end
