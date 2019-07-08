RSpec.shared_examples 'services/concerns/upload_base' do |type|
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding) }
  let(:params) { { user: user, import: import } }
  let(:row_values_module) do
    "BiddingsService::Upload::All::RowValues::#{type.capitalize}".constantize
  end
  let(:row_delivery_price_module) do
    "BiddingsService::Upload::All::RowDeliveryPrice::#{type.capitalize}".constantize
  end
  let(:open_book_file) { spreadsheet.send(open_method, file) }

  describe '#initialize' do
    let(:bidding) { create(:bidding) }

    subject { described_class.new(params) }

    it { expect(subject.import).to eq(import) }
  end

  describe '.call!' do
    let(:file) do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/myfiles/#{file_name}")
      )
    end
    let(:row_values) { lines.map { |line| row_values_module.new(line) } }

    before do
      allow(spreadsheet).to receive(open_method).and_return(open_book_file)
    end

    subject { described_class.call!(params) }

    context 'when it runs with failures' do
      context 'when delivery_price is nil' do
        let(:file_name) { "proposal_upload_1_1.#{type}" }

        before { allow(row_delivery_price_module).to receive(:call).and_return(nil) }

        it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'when sheet is empty' do
        let(:file_name) { "proposal_upload_empty.#{type}" }

        it { expect { subject }.not_to change { Proposal.count } }
      end

      context 'when not founding records' do
        let(:file_name) { "proposal_upload_1_1.#{type}" }

        context 'and bidding not exists' do
          before { allow(Bidding).to receive(:find_by).and_return(nil) }

          it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
        end

        context 'and lot not exists' do
          before do
            allow(Bidding).to receive(:find_by).and_return(bidding)
            allow(bidding).
              to receive_message_chain(:lots, :find_by).and_return(nil)
          end

          it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
        end

        context 'and lot_group_item not exists' do
          let(:lot) { bidding.lots.first }

          before do
            allow(Bidding).to receive(:find_by).and_return(bidding)
            allow(bidding).to receive_message_chain(:lots, :find_by).
              and_return(lot)
            allow(lot).to receive_message_chain(:lot_group_items, :find_by).
              and_return(nil)
          end

          it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
        end
      end
    end

    context 'when it runs successfully' do
      before do
        allow(Bidding).to receive(:find_by).and_return(bidding)
        allow(row_values_module).to receive(:new).and_return(*row_values)
        allow(row_delivery_price_module).to receive(:call).and_return(100)

        response = double('api_response', success?: true)
        allow(Blockchain::Proposal::Create).to receive(:call).and_return(response)

        allow_any_instance_of(described_class).
          to receive(:from_another_bidding?).and_return(false)
        allow_any_instance_of(described_class).
          to receive(:invalid_items_quantity?).and_return(false)
      end

      context 'when there is already a proposal' do
        let(:lot_group_items) { create_list(:lot_group_item, 1) }
        let(:lot) do
          create(:lot, build_lot_group_item: false,
                       lot_group_items: lot_group_items)
        end
        let(:bidding) { create(:bidding, build_lot: false, lots: [lot]) }
        let(:lot_group_item_lot_proposal) do
          create(:lot_group_item_lot_proposal, price: 5)
        end
        let(:lot_proposal) do
          create(:lot_proposal, build_lot_group_item_lot_proposal: false,
                                lot: lot,
                                supplier: user,
                                lot_group_item_lot_proposals: [lot_group_item_lot_proposal],
                                delivery_price: 5)
        end
        let!(:proposal) do
          create(:proposal, build_lot_proposal: false, bidding: bidding,
                            lot_proposals: [lot_proposal], provider: provider,
                            import_creating: true)
        end
        let(:file_name) { "proposal_upload_1_1.#{type}" }
        let(:lines) do
          [
            [bidding.id, lot.id, nil, nil, lot_group_items.first.id, nil, nil, nil, 100]
          ]
        end

        before do
          allow(bidding).to receive_message_chain(:lots, :find_by).and_return(lot)
          allow_any_instance_of(described_class).
            to receive(:lot_group_item_lot_proposal).
            and_return(lot_group_item_lot_proposal)
        end

        it { expect { subject }.not_to change { Proposal.count } }

        context 'when validating fields' do
          before do
            subject
            @proposal = Proposal.last
          end

          it { expect(@proposal.status).to eq(proposal.status) }

          it { expect(@proposal.lot_proposals.size).to eq(1) }
          it { expect(@proposal.lot_proposals.last.delivery_price).to eq(100) }

          it { expect(@proposal.lot_group_item_lot_proposals.size).to eq(1) }
          it { expect(@proposal.lot_group_item_lot_proposals.last.price).to eq(100) }
        end
      end

      context 'when is 1 lot' do
        let(:lot) { create(:lot, build_lot_group_item: false, lot_group_items: lot_group_items) }
        let(:bidding) { create(:bidding, build_lot: false, lots: [lot]) }

        before do
          allow(bidding).to receive_message_chain(:lots, :find_by).and_return(lot)
        end

        context 'and is 1 lot_group_item' do
          let(:file_name) { "proposal_upload_1_1.#{type}" }
          let(:lot_group_items) { create_list(:lot_group_item, 1) }
          let(:lines) do
            [
              [bidding.id, lot.id, nil, lot_group_items.first.id, nil, nil, nil, nil, 100]
            ]
          end

          it { expect { subject }.to change { Proposal.count }.by(1) }

          context 'when validating fields' do
            before do
              subject
              @proposal = Proposal.last
            end

            it { expect(@proposal.status).to eq('draft') }

            it { expect(@proposal.lot_proposals.size).to eq(1) }
            it { expect(@proposal.lot_proposals.last.delivery_price).to eq(100) }

            it { expect(@proposal.lot_group_item_lot_proposals.size).to eq(1) }
            it { expect(@proposal.lot_group_item_lot_proposals.last.price).to eq(100) }
          end
        end

        context 'and is 2 lot_group_items' do
          let(:file_name) { "proposal_upload_1_2.#{type}" }
          let(:lot_group_items) { create_list(:lot_group_item, 2) }
          let(:lines) do
            [
              [bidding.id, lot.id, nil, lot_group_items.first.id, nil, nil, nil, nil, 100],
              [bidding.id, lot.id, nil, lot_group_items.last.id, nil, nil, nil, nil, 200]
            ]
          end

          it { expect { subject }.to change { Proposal.count }.by(1) }

          context 'when validating fields' do
            before do
              subject
              @proposal = Proposal.last
            end

            it { expect(@proposal.status).to eq('draft') }

            it { expect(@proposal.lot_proposals.size).to eq(1) }
            it { expect(@proposal.lot_proposals.last.delivery_price).to eq(100) }

            it { expect(@proposal.lot_group_item_lot_proposals.size).to eq(2) }
            it { expect(@proposal.lot_group_item_lot_proposals.first.price).to eq(100) }
            it { expect(@proposal.lot_group_item_lot_proposals.last.price).to eq(200) }
          end
        end
      end

      context 'when is 2 lots' do
        let(:bidding) { create(:bidding, build_lot: false, lots: lots) }

        before do
          allow(bidding).to receive_message_chain(:lots, :find_by).and_return(*lots)
        end

        context 'and is 1 lot_group_item for each' do
          let(:file_name) { "proposal_upload_2_1.#{type}" }
          let(:lot_group_items) { create_list(:lot_group_item, 2) }
          let(:lots) do
            [
              create(:lot, build_lot_group_item: false, lot_group_items: [lot_group_items.first]),
              create(:lot, build_lot_group_item: false, lot_group_items: [lot_group_items.last])
            ]
          end
          let(:lines) do
            [
              [bidding.id, lots.first.id, nil, lot_group_items.first.id, nil, nil, nil, nil, 100],
              [bidding.id, lots.last.id, nil, lot_group_items.last.id, nil, nil, nil, nil, 200]
            ]
          end

          it { expect { subject }.to change { Proposal.count }.by(1) }

          context 'when validating fields' do
            before do
              subject
              @proposal = Proposal.last
            end

            it { expect(@proposal.status).to eq('draft') }

            it { expect(@proposal.lot_proposals.size).to eq(2) }
            it { expect(@proposal.lot_proposals.first.delivery_price).to eq(100) }
            it { expect(@proposal.lot_proposals.last.delivery_price).to eq(100) }

            it { expect(@proposal.lot_group_item_lot_proposals.size).to eq(2) }
            it { expect(@proposal.lot_group_item_lot_proposals.first.price).to eq(100) }
            it { expect(@proposal.lot_group_item_lot_proposals.last.price).to eq(200) }
          end
        end

        context 'and is 2 lot_group_items for each' do
          let(:file_name) { "proposal_upload_2_2.#{type}" }
          let(:lot_group_items) { create_list(:lot_group_item, 2) }
          let(:another_lot_group_items) { create_list(:lot_group_item, 2) }
          let(:lots) do
            [
              create(:lot, build_lot_group_item: false, lot_group_items: lot_group_items),
              create(:lot, build_lot_group_item: false, lot_group_items: another_lot_group_items)
            ]
          end
          let(:lines) do
            [
              [bidding.id, lots.first.id, nil, lot_group_items.first.id, nil, nil, nil, nil, 100],
              [bidding.id, lots.first.id, nil, lot_group_items.last.id, nil, nil, nil, nil, 200],
              [bidding.id, lots.last.id, nil, another_lot_group_items.first.id, nil, nil, nil, nil, 300],
              [bidding.id, lots.last.id, nil, another_lot_group_items.last.id, nil, nil, nil, nil, 400]
            ]
          end

          it { expect { subject }.to change { Proposal.count }.by(1) }

          context 'when validating fields' do
            before do
              subject
              @proposal = Proposal.last
            end

            it { expect(@proposal.status).to eq('draft') }

            it { expect(@proposal.lot_proposals.size).to eq(2) }
            it { expect(@proposal.lot_proposals.first.delivery_price).to eq(100) }
            it { expect(@proposal.lot_proposals.last.delivery_price).to eq(100) }

            it { expect(@proposal.lot_group_item_lot_proposals.size).to eq(4) }
            it { expect(@proposal.lot_group_item_lot_proposals[0].price).to eq(100) }
            it { expect(@proposal.lot_group_item_lot_proposals[1].price).to eq(200) }
            it { expect(@proposal.lot_group_item_lot_proposals[2].price).to eq(300) }
            it { expect(@proposal.lot_group_item_lot_proposals[3].price).to eq(400) }
          end
        end
      end
    end
  end
end
