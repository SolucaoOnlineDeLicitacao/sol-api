=begin
  Módulo base para criação de notificações, todos os demais serviços devem
  utilizar este serviço base.

  Todo serviço criado deve implementar os metodos "initialize" e "self.call"
  e sobrescrever os métodos notifiable e receivables, os quais são utilizados
  para definir qual o recurso a ser notificado (notifiable) e quais recursos
  serão notificados (receivables)

  Existem 3 formas de notificar os recursos:
  1.  Notificação simples, com a mesma mensagem para um conjunto de recursos
      da mesma classe;
        Ex: Notifications::Biddings::Approved

  2.  Notificação simples, com a mesma mensagem para mais de um conjunto
      de recursos de multiplas classes;
        Ex: Notifications::Biddings::Finished

  3.  Notificação complexas onde é necessário notificar mais de um conjunto
      de recursos de multiplas classes com mensagens diferentes.
        Ex: Notifications::Biddings::UnderReview

    Neste caso (3) nós temos um "serviço gerenciador" de notificações "UnderReview"
    o qual é responsável por chamar os serviços de notificações específicos para
    cada tipo de recurso (que é um serviço do tipo 1)

=end

module Notifications
  class Base

    def call
      notify
    end

    def self.call
      new.call
    end

    private

    def notify
      return unless receivables.present?

      receivable_list.each do |receiver|
        notification = Notification.create(notification_attributes(receiver))

        ::Notifications::Fcm.delay.call(notification.id) if notification
      end
    end

    def notification_attributes(receiver)
      {
        receivable: receiver,
        notifiable: notifiable,
        action: action,
        title_args: title_args,
        body_args: body_args,
        extra_args: extra_args
      }
    end

    def action
      # dynamic creates the action name
      # Notifications::Biddings::CancellationRequests::Reproved
      # turns into "bidding.cancellation_request_reproved"
      "#{actions[1]}.#{action_body}"
    end

    def actions
      self.class.to_s.underscore.split('/').map(&:singularize)
    end

    def action_body
      actions[2..-1].join('_')
    end

    def receivable_list
      # Wraps and flattens the receivables se we can pass a array of collections ([users, suppliers])
      # or a single object i.e admin
      @receivable_list ||= Array.wrap(receivables).flatten
    end

    # the resources that are going to be notified about the notifiable resource
    # MUST BE OVERRIDDEN
    # should be an object or an array of objects
    def receivables; end

    # the notifiable resource so we know which resource is been notified
    # MUST BE OVERRIDDEN
    # should be a single object
    def notifiable; end

    # used to generate the body text by filling its gaps with string interpolation (%s)
    # should be a string or an array of strings
    def body_args; end

    # used to generate the title text by filling its gaps with string interpolation (%s)
    # should be a string or an array of strings
    def title_args; end

    # used to send extra ids, ex: { resource_id: resource.id }, so we can
    # mount the route if needed
    # should be a hash
    def extra_args; end

  end
end
