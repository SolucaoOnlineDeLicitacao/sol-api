RSpec.shared_examples "controllers/concerns/imports_controller" do
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding, status: :ongoing) }
  let(:resource_class) { resource.class.to_s }
  let(:resource_name) { resource_class.underscore.to_s }
  let(:lot_proposal_import?) { resource_name == 'lot_proposal_import' }
  let(:serializer) { "Supp::#{resource_class}Serializer".constantize }
  let(:service) { "BiddingsService::#{resource_class}s::Create".constantize }

  before { oauth_token_sign_in user }

  describe '#show' do
    let(:params) { base_params.merge(id: resource) }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.bidding).to eq(bidding) }
      it { expect(controller.lot).to eq(lot) if lot_proposal_import? }
      it { expect(controller.send(resource_name)).to eq resource }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, resource) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let(:params) do
      base_params.merge("#{resource_name}": { file: File.open(resource.file.url) })
    end
    let(:service_response) { true }

    before do
      allow(service).to receive(:async_call).and_return(service_response)
    end

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'write'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.bidding).to eq(bidding) }
      it { expect(controller.lot).to eq(lot) if lot_proposal_import? }
      it { expect(controller.send(resource_name)).to be_a_new(resource_class.constantize) }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before { post_create }

        it { expect(response).to have_http_status :created }
        it { expect(json[resource_name]).to be_present }
      end

      context 'when not created' do
        let(:service_response) { false }

        before do
          allow(controller.send(resource_name)).
            to receive(:errors_as_json).and_return(error: 'value')

          post_create
        end

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(json['errors']).to be_present }
      end
    end
  end
end
