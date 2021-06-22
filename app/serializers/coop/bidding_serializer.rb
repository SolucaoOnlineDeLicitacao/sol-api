module Coop
  class BiddingSerializer < ActiveModel::Serializer
    include CurrentEventCancellable

    attributes :id, :title, :description, :kind, :status, :deadline, :link,
        :start_date, :closing_date, :covenant_id, :covenant_name,
        :cancel_comment, :comment_response, :event_status, :event_id, :address,
        :can_finish, :supp_can_see, :modality, :draw_end_days, :refuse_comment,
        :failure_comment, :minute_pdf, :edict_pdf, :classification_id, :classification_name,
        :all_lots_failure, :code, :position, :estimated_cost_total, :proposal_import_file_url,
        :user_role

    has_one :cooperative, through: :covenant, serializer: Supp::CooperativeSerializer

    has_many :additives

    has_many :contracts, serializer: Coop::ContractSerializer

    def proposal_import_file_url
      object.proposal_import_file&.url
    end

    def refuse_comment
      current_refuse_event&.comment
    end

    def failure_comment
      current_failure_event&.comment
    end

    def minute_pdf
      object.merged_minute_document.try(:file).try(:url)
    end

    def edict_pdf
      object.edict_document.try(:file).try(:url)
    end

    def cancel_comment
      current_event&.comment
    end

    def event_status
      current_event&.status
    end

    def event_id
      current_event&.id
    end

    def covenant_name
      "#{object.covenant.number} - #{object.covenant.name}"
    end

    def can_finish
      (object.under_review? || object.reopened?) && allowed_to_finish?
    end

    def supp_can_see
      object.finnished?
    end

    def all_lots_failure
      object.fully_failed_lots?
    end

    def user_role
      current_user.class == Admin ? current_user.role : ''
    end

    private

    def lots
      object.lots
    end

    def allowed_to_finish?
      ( object.lots.pluck(:status) - ["accepted", "desert", "failure"]).empty?
    end

    def event_resource
      object
    end

    def current_refuse_event
      object.event_bidding_reproveds&.last
    end

    def current_failure_event
      object.event_bidding_failures&.last
    end
  end
end
