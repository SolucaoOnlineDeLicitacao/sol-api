require 'rails_helper'

RSpec.describe Administrator::ReportsController, type: :controller do
  let(:user) { create(:admin) }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:report_1) { create(:report, report_type: :biddings, status: :waiting) }
    let(:report_2) { create(:report, report_type: :contracts, status: :waiting) }
    let(:report_3) { create(:report, report_type: :biddings, status: :processing) }
    let(:report_4) { create(:report, report_type: :contracts, status: :processing) }
    let!(:reports) { [report_1, report_2, report_3, report_4] }

    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Report }
    end

    describe 'helpers' do
      let!(:params) do
        { page: 2, sort_column: 'created_at', sort_direction: 'desc' }
      end

      let(:exposed_reports) { Report.all }

      before do
        allow(exposed_reports).to receive(:sorted) { exposed_reports }
        allow(exposed_reports).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:reports) { exposed_reports }

        get_index
      end

      it { expect(exposed_reports).to have_received(:sorted).with('created_at', 'desc') }
      it { expect(exposed_reports).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.reports).to eq reports }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }

        let(:expected_json) do
          reports.map do |user|
            Administrator::ReportSerializer.new(user).
              serializable_hash.as_json.deep_stringify_keys
          end.reverse
        end

        context 'without params' do
          it { expect(json).to eq expected_json }
        end

        context 'with report_type params' do
          let!(:reports) { [report_1, report_3] }
          let(:params) { { report_type: 'biddings' } }

          it { expect(json).to eq expected_json }
        end

        context 'with status params' do
          let!(:reports) { [report_3, report_4] }
          let(:params) { { status: 'processing' } }

          it { expect(json).to eq expected_json }
        end

        context 'with report_type and status params' do
          let!(:reports) { [report_3] }
          let(:params) { { report_type: 'biddings', status: 'processing' } }

          it { expect(json).to eq expected_json }
        end
      end
    end
  end

  describe '#show' do
    let!(:report) { create(:report) }
    let(:params) { { id: report } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it_behaves_like 'an admin authorization to', 'user', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.report).to eq report }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      let(:expected_json) do
        Administrator::ReportSerializer.new(report).
          serializable_hash.as_json.deep_stringify_keys
      end

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let(:report) { create(:report) }
    let(:params) { { report: { report_type: report.report_type } } }
    let(:service_response) { double('service_response', async_call: true, report: report) }

    before do
      allow(ReportsService::Create).
        to receive(:new).with(admin: user, report_type: 'biddings').
        and_return(service_response)
    end

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.report).to be_instance_of Report }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before { post_create }

        it { expect(response).to have_http_status :created }
        it { expect(json['report']).to be_present }
      end

      context 'when not created' do
        before do
          allow(report).to receive(:valid?) { false }
          allow(controller.report).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
