require 'rails_helper'

RSpec.describe Integration::Configuration, type: :model do
  describe 'enums' do
    let(:expected){ %i[queued in_progress success fail] }

    it { is_expected.to define_enum_for(:status).with_values(expected).with_prefix }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :type }
    it { is_expected.to validate_presence_of :endpoint_url }
    it { is_expected.to validate_presence_of :token }
    it { is_expected.to validate_cron_syntax_for :schedule }

    context 'endpoint_url uniqueness' do
      before { build(:integration_configuration) }

      it { is_expected.to validate_uniqueness_of(:endpoint_url).case_insensitive }
    end
  end

  describe 'methods' do
    describe '.integrated?' do
      subject { described_class.integrated? }

      context 'when count > 0' do
        before { allow(described_class).to receive(:count) { 3 } }

        it { is_expected.to be_truthy }
      end

      context 'when count <= 0' do
        it { is_expected.to be_falsy }
      end
    end
  end

  describe 'callbacks' do
    describe 'after_commit' do
      with_versioning do
        describe '.update_crontab' do
          let(:configuration) { build(:integration_cooperative_configuration) }

          before { subject }

          context 'when schedule changed' do
            subject do
              configuration.save!
              configuration.update!(schedule: '10 * * * *')
            end

            it { expect(described_class).to have_received(:execute_whenever) }
          end

          context 'when schedule not changed' do
            subject { configuration.save! }

            it { expect(described_class).not_to have_received(:execute_whenever) }
          end
        end
      end
    end
  end
end
