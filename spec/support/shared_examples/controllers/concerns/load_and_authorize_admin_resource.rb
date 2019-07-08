RSpec.shared_examples 'an admin authorization to' do |admin_var, operation|
  describe "#{operation}" do
    context 'when the admin role is viewer' do
      before { send(admin_var).viewer! }

      if operation == 'read' || operation.include?('himself')
        it { expect(response).to be_present }
      else
        it { expect { subject }.to raise_error(CanCan::AccessDenied) }
      end
    end

    context 'when the admin role is general' do
      before { send(admin_var).general! }

      it { expect(response).to be_present }
    end

    context 'when the admin role is reviewer' do
      before { send(admin_var).reviewer! }

      it { expect(response).to be_present }
    end
  end
end
