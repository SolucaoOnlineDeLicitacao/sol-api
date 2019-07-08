require 'rails_helper'

RSpec.describe Coop::BiddingSerializer, type: :serializer do
  let(:merged_minute_document) { create(:document) }
  let(:edict_document) { create(:document) }
  let(:object) do
    create :bidding, merged_minute_document: merged_minute_document,
                     edict_document: edict_document
  end

  subject { format_json(described_class, object) }

  describe 'attributes' do
    let(:can_finish) do
      (object.under_review? || object.reopened?) &&
        (object.lots.pluck(:status) - ["accepted", "desert", "failure"]).empty?
    end

    let(:supp_can_see) { object.finnished? }

    let(:covenant_number_name) { "#{object.covenant.number} - #{object.covenant.name}" }

    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'title' => object.title }
    it { is_expected.to include 'description' => object.description }
    it { is_expected.to include 'kind' => object.kind }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'deadline' => object.deadline }
    it { is_expected.to include 'link' => object.link }
    it { is_expected.to include 'start_date' => object.start_date.to_s }
    it { is_expected.to include 'closing_date' => object.closing_date.to_s }
    it { is_expected.to include 'covenant_id' => object.covenant_id }
    it { is_expected.to include 'covenant_name' => covenant_number_name }
    it { is_expected.to include 'address' => object.address }
    it { is_expected.to include 'can_finish' => can_finish }
    it { is_expected.to include 'supp_can_see' => supp_can_see }
    it { is_expected.to include 'modality' => object.modality }
    it { is_expected.to include 'draw_end_days' => object.draw_end_days }
    it { is_expected.to include 'classification_id' => object.classification_id }
    it { is_expected.to include 'classification_name' => object.classification_name }
    it { is_expected.to include 'estimated_cost_total' => object.estimated_cost_total }
    it { is_expected.to include 'all_lots_failure' => false }
    it { is_expected.to include 'code' => object.code }
    it { is_expected.to include 'position' => object.position }
    it { is_expected.to include 'proposal_import_file_url' => object.proposal_import_file&.url }
    it { expect(subject['minute_pdf']).to include('file.pdf')}
    it { expect(subject['edict_pdf']).to include('file.pdf')}


    describe 'cancel_comment' do
      let!(:change) do
        create(:event_bidding_cancellation_request, from: 'draft', to: 'canceled',
          eventable: object, comment: 'Oh noes', comment_response: 'Oh yeah',
          status: 'approved')
      end

      let(:event) do
        object.event_cancellation_requests&.changing_to('canceled')
          &.last
      end

      it { is_expected.to include 'cancel_comment' => event.comment }
      it { is_expected.to include 'comment_response' => event.comment_response }
      it { is_expected.to include 'event_status' => event.status }
      it { is_expected.to include 'event_id' => event.id }
    end

    describe 'refuse_comment' do
      let!(:change) do
        create(:event_bidding_reproved, from: 'waiting', to: 'draft',
          eventable: object, comment: 'Oh noes')
      end

      let(:event) do
        object.event_bidding_reproveds&.last
      end

      it { is_expected.to include 'refuse_comment' => event.comment }
    end

    describe 'failure_comment' do
      let!(:failure) do
        create(:event_bidding_failure, from: 'waiting', to: 'failure',
          eventable: object, comment: 'Oh noes')
      end

      let(:event) do
        object.event_bidding_failures&.last
      end

      it { is_expected.to include 'failure_comment' => event.comment }
    end
  end

  describe 'associations' do
    describe 'cooperative' do
      let(:serialized_cooperative) { format_json(Supp::CooperativeSerializer, object.cooperative) }

      it { expect(subject['cooperative']).to eq serialized_cooperative }
    end

    describe 'additives' do
      let!(:additive) { create(:additive, bidding: object) }

      let(:serialized_additives) do
        object.additives.map { |additive| format_json(AdditiveSerializer, additive) }
      end

      it { expect(subject['additives']).to eq serialized_additives }
    end

    describe 'contracts' do
      let!(:contract) { create(:contract, bidding: object) }

      let(:serialized_contracts) do
        object.contracts.map { |contract| format_json(Coop::ContractSerializer, contract) }
      end

      it { expect(subject['contracts']).to eq serialized_contracts }
    end
  end
end
