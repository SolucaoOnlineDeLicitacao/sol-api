RSpec.shared_examples 'an integration authorization to' do |admin_var|
  context 'when the admin role is general' do
    before { send(admin_var).general! }

    context 'when there are integrations' do
      let!(:configuration) { create(:integration_covenant_configuration) }

      it { expect { subject }.to raise_error(CanCan::AccessDenied) }
    end

    context 'when there are not integrations' do
      it { expect(response).to be_present }
    end

  end

  context 'when the admin role is reviewer' do
    before { send(admin_var).reviewer! }

    context 'when there are integrations' do
      let!(:configuration) { create(:integration_covenant_configuration) }

      it { expect { subject }.to raise_error(CanCan::AccessDenied) }
    end

    context 'when there are not integrations' do
      it { expect(response).to be_present }
    end
  end
end
