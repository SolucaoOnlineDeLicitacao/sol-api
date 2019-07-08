require 'rails_helper'

RSpec.describe ReportsService::Create, type: :service do
  let(:admin) { create(:admin) }
  let(:params) { { admin: admin, report_type: report_type } }
  let(:report_type) { 'biddings' }

  let(:service) { described_class.new(params) }

  describe '#initialize' do
    subject { service }

    it { expect(subject.admin).to eq(admin) }
    it { expect(subject.report_type).to eq(report_type) }
  end

  describe '.async_call' do
    before { Sidekiq::Worker.clear_all }

    subject { service.async_call }

    context 'when report_type is biddings' do
      let(:worker) { Reports::BiddingsWorker }

      context 'and it runs successfully' do
        before { allow(worker).to receive(:perform_async) }

        it { is_expected.to be_truthy }
        it { expect { subject }.to change { Report.count }.by(1) }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).to have_received(:perform_async) }
        end
      end

      context 'and it runs with failures' do
        before do
          allow(Report).to receive(:create!).
            and_raise(ActiveRecord::RecordInvalid)

          allow(worker).to receive(:perform_async)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { Report.count } }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).not_to have_received(:perform_async) }
        end
      end
    end

    context 'when report_type is contracts' do
      let(:report_type) { 'contracts' }
      let(:worker) { Reports::ContractsWorker }

      context 'and it runs successfully' do
        before { allow(worker).to receive(:perform_async) }

        it { is_expected.to be_truthy }
        it { expect { subject }.to change { Report.count }.by(1) }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).to have_received(:perform_async) }
        end
      end

      context 'and it runs with failures' do
        before do
          allow(Report).to receive(:create!).
            and_raise(ActiveRecord::RecordInvalid)

          allow(worker).to receive(:perform_async)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { Report.count } }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).not_to have_received(:perform_async) }
        end
      end
    end

    context 'when report_type is time' do
      let(:report_type) { 'time' }
      let(:worker) { Reports::TimeWorker }

      context 'and it runs successfully' do
        before { allow(worker).to receive(:perform_async) }

        it { is_expected.to be_truthy }
        it { expect { subject }.to change { Report.count }.by(1) }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).to have_received(:perform_async) }
        end
      end

      context 'and it runs with failures' do
        before do
          allow(Report).to receive(:create!).
            and_raise(ActiveRecord::RecordInvalid)

          allow(worker).to receive(:perform_async)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { Report.count } }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).not_to have_received(:perform_async) }
        end
      end
    end

    context 'when report_type is items' do
      let(:report_type) { 'items' }
      let(:worker) { Reports::ItemsWorker }

      context 'and it runs successfully' do
        before { allow(worker).to receive(:perform_async) }

        it { is_expected.to be_truthy }
        it { expect { subject }.to change { Report.count }.by(1) }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).to have_received(:perform_async) }
        end
      end

      context 'and it runs with failures' do
        before do
          allow(Report).to receive(:create!).
            and_raise(ActiveRecord::RecordInvalid)

          allow(worker).to receive(:perform_async)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { Report.count } }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).not_to have_received(:perform_async) }
        end
      end
    end

    context 'when report_type is suppliers_biddings' do
      let(:report_type) { 'suppliers_biddings' }
      let(:worker) { Reports::SuppliersBiddingsWorker }

      context 'and it runs successfully' do
        before { allow(worker).to receive(:perform_async) }

        it { is_expected.to be_truthy }
        it { expect { subject }.to change { Report.count }.by(1) }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).to have_received(:perform_async) }
        end
      end

      context 'and it runs with failures' do
        before do
          allow(Report).to receive(:create!).
            and_raise(ActiveRecord::RecordInvalid)

          allow(worker).to receive(:perform_async)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { Report.count } }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).not_to have_received(:perform_async) }
        end
      end
    end

    context 'when report_type is suppliers_contracts' do
      let(:report_type) { 'suppliers_contracts' }
      let(:worker) { Reports::SuppliersContractsWorker }

      context 'and it runs successfully' do
        before { allow(worker).to receive(:perform_async) }

        it { is_expected.to be_truthy }
        it { expect { subject }.to change { Report.count }.by(1) }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).to have_received(:perform_async) }
        end
      end

      context 'and it runs with failures' do
        before do
          allow(Report).to receive(:create!).
            and_raise(ActiveRecord::RecordInvalid)

          allow(worker).to receive(:perform_async)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { Report.count } }

        describe 'worker validation' do
          before { subject }

          it { expect(worker).not_to have_received(:perform_async) }
        end
      end
    end
  end

  describe '.call' do
    subject { service.call }

    context 'when it runs successfully' do
      it { is_expected.to be_truthy }
      it { expect { subject }.to change { Report.count }.by(1) }

      describe 'validating attributes' do
        before { subject }

        it { expect(service.report.admin).to eq(admin) }
        it { expect(service.report.status).to eq('waiting') }
        it { expect(service.report.url).to be_nil }
        it { expect(service.report.error_message).to be_nil }
        it { expect(service.report.error_backtrace).to be_nil }

        context 'and report_type is biddings' do
          it { expect(service.report.report_type).to eq('biddings') }
        end

        context 'and report_type is contracts' do
          let(:report_type) { 'contracts' }

          it { expect(service.report.report_type).to eq('contracts') }
        end

        context 'and report_type is time' do
          let(:report_type) { 'time' }

          it { expect(service.report.report_type).to eq('time') }
        end

        context 'and report_type is items' do
          let(:report_type) { 'items' }

          it { expect(service.report.report_type).to eq('items') }
        end

        context 'and report_type is suppliers_biddings' do
          let(:report_type) { 'suppliers_biddings' }

          it { expect(service.report.report_type).to eq('suppliers_biddings') }
        end

        context 'and report_type is suppliers_contracts' do
          let(:report_type) { 'suppliers_contracts' }

          it { expect(service.report.report_type).to eq('suppliers_contracts') }
        end
      end
    end

    context 'when it runs with failures' do
      context 'and create! returns ActiveRecord::RecordInvalid' do
        before do
          allow(Report).to receive(:create!).
            and_raise(ActiveRecord::RecordInvalid)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { Report.count } }
      end

      context 'and without report_type' do
        let(:params) { { admin: admin } }

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { Report.count } }
      end

      context 'and report_type is invalid' do
        let(:params) { { admin: admin, report_type: 'test' } }

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { Report.count } }
      end

      context 'and without admin' do
        let(:params) { { report_type: report_type } }

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { Report.count } }
      end
    end
  end
end
