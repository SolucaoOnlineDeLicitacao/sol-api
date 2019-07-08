require 'rails_helper'

RSpec.describe Administrator::Reports::DownloadsController, type: :controller do
  let(:user) { create(:admin) }

  before { oauth_token_sign_in user }

  describe '#show' do
    let(:params) { { report_id: report.id } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before do
      allow(controller).to receive(:send_file).and_call_original

      get_show
    end

    context 'when has url' do
      let(:file_path) do
        File.join(Rails.root, '/spec/fixtures/myfiles/file.pdf')
      end
      let(:report) { create(:report, url: file_path) }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.report).to eq report }
      end

      describe 'response' do
        it { expect(controller).to have_received(:send_file) }
      end
    end

    context 'when there is no url' do
      let(:report) { create(:report) }

      describe 'http_status' do
        it { expect(response).to have_http_status :not_found }
      end

      describe 'exposes' do
        it { expect(controller.report).to eq report }
      end

      describe 'response' do
        it { expect(controller).not_to have_received(:send_file) }
      end
    end
  end
end
