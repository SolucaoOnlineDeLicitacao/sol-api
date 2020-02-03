RSpec.shared_examples 'services/concerns/contract_classification' do

  let!(:user) { create(:user) }

  let!(:providers) { create_list(:provider, 2, :skip_validation, skip_classification: true) }
  let!(:provider) { providers.first }
  let!(:provider_2) { providers.last }

  let!(:supplier) { create(:supplier, provider: provider) }
  let!(:supplier_2) { create(:supplier, provider: provider_2) }

  let!(:item_1) { create(:item, classification: classification_1) }
  let!(:item_2) { create(:item, classification: classification_2) }
  let!(:item_3) { create(:item, classification: classification_3) }
  let!(:item_4) { create(:item, classification: classification_1) }

  let!(:covenant) { create(:covenant, group: false) }

  let!(:group_1) do
    create(:group, :skip_validation, build_group_itens: false, covenant: covenant)
  end

  let!(:group_2) do
    create(:group, :skip_validation, build_group_itens: false, covenant: covenant)
  end

  let!(:group_3) do
    create(:group, :skip_validation, build_group_itens: false, covenant: covenant)
  end

  let!(:group_item_1) { create(:group_item, group: group_1, item: item_1) }
  let!(:group_item_2) { create(:group_item, group: group_2, item: item_2) }
  let!(:group_item_3) { create(:group_item, group: group_3, item: item_3) }
  let!(:group_item_4) { create(:group_item, group: group_3, item: item_4) }

  let!(:bidding_1) do
    create(:bidding, build_lot: false, covenant: covenant, classification: classification_1,
                     status: :draft, kind: :unitary)
  end

  let!(:bidding_2) do
    create(:bidding, build_lot: false, covenant: covenant, classification: classification_2,
                     status: :draft, kind: :lot)
  end

  let!(:bidding_3) do
    create(:bidding, build_lot: false, covenant: covenant, classification: classification_3,
                     status: :draft, kind: :lot)
  end

  let!(:bidding_4) do
    create(:bidding, build_lot: false, covenant: covenant, classification: classification_1,
                     status: :draft, kind: :global)
  end

  let!(:lot_1) do
    create(:lot, :skip_validation, bidding: bidding_1,
        build_lot_group_item: false)
  end

  let!(:lot_2) do
    create(:lot, :skip_validation, bidding: bidding_2,
        build_lot_group_item: false)
  end

  let!(:lot_3) do
    create(:lot, :skip_validation, bidding: bidding_3,
        build_lot_group_item: false)
  end

  let!(:lot_4) do
    create(:lot, :skip_validation, bidding: bidding_4,
        build_lot_group_item: false)
  end

  let!(:lot_group_item_1) do
    create(:lot_group_item, group_item: group_item_1, lot: lot_1)
  end

  let!(:lot_group_item_2) do
    create(:lot_group_item, group_item: group_item_2, lot: lot_2)
  end

  let!(:lot_group_item_3) do
    create(:lot_group_item, group_item: group_item_3, lot: lot_3)
  end

  let!(:lot_group_item_4) do
    create(:lot_group_item, group_item: group_item_4, lot: lot_4)
  end

  let!(:proposal_1) do
    proposal = create(:proposal, build_lot_proposal: false, bidding: bidding_1,
        provider: provider)
    proposal.update_column(:price_total, 1)
    proposal
  end

  let!(:proposal_2) do
    proposal = create(:proposal, build_lot_proposal: false, bidding: bidding_2,
        provider: provider)

    proposal.update_column(:price_total, 2)
    proposal
  end

  let!(:proposal_3) do
    proposal = create(:proposal, build_lot_proposal: false, bidding: bidding_3,
        provider: provider)
    proposal.update_column(:price_total, 3)
    proposal
  end

  let!(:proposal_4) do
    proposal = create(:proposal, build_lot_proposal: false, bidding: bidding_4,
        provider: provider)
    proposal.update_column(:price_total, 4)
    proposal
  end

  let!(:proposal_5) do
    proposal = create(:proposal, build_lot_proposal: false, bidding: bidding_4,
        provider: provider_2)
    proposal.update_column(:price_total, 4)
    proposal
  end

  let!(:proposal_6) do
    proposal = create(:proposal, build_lot_proposal: false, bidding: bidding_3,
        provider: provider_2)
    proposal.update_column(:price_total, 3)
    proposal
  end

  let!(:lot_proposal_1) do
    create(:lot_proposal, build_lot_group_item_lot_proposal: false,
        lot: lot_1, proposal: proposal_1, supplier: supplier)
  end

  let!(:lot_proposal_2) do
    create(:lot_proposal, build_lot_group_item_lot_proposal: false,
        lot: lot_2, proposal: proposal_2, supplier: supplier)
  end

  let!(:lot_proposal_3) do
    create(:lot_proposal, build_lot_group_item_lot_proposal: false,
        lot: lot_3, proposal: proposal_3, supplier: supplier)
  end

  let!(:lot_proposal_4) do
    create(:lot_proposal, build_lot_group_item_lot_proposal: false,
        lot: lot_4, proposal: proposal_4, supplier: supplier)
  end

  let!(:lot_proposal_5) do
    create(:lot_proposal, build_lot_group_item_lot_proposal: false,
        lot: lot_4, proposal: proposal_5, supplier: supplier_2)
  end

  let!(:lot_proposal_6) do
    create(:lot_proposal, build_lot_group_item_lot_proposal: false,
        lot: lot_3, proposal: proposal_6, supplier: supplier_2)
  end

  let!(:lot_group_item_lot_proposal_1) do
    create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_1,
        lot_group_item: lot_group_item_1)
  end

  let!(:lot_group_item_lot_proposal_2) do
    create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_2,
        lot_group_item: lot_group_item_2)
  end

  let!(:lot_group_item_lot_proposal_3) do
    create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_3,
        lot_group_item: lot_group_item_3)
  end

  let!(:lot_group_item_lot_proposal_4) do
    create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_4,
        lot_group_item: lot_group_item_4)
  end

  let!(:lot_group_item_lot_proposal_5) do
    create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_5,
        lot_group_item: lot_group_item_1)
  end

  let!(:lot_group_item_lot_proposal_6) do
    create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_6,
        lot_group_item: lot_group_item_3)
  end

  let!(:contract_1) { create(:contract, proposal: proposal_1, user: user) }
  let!(:contract_2) { create(:contract, proposal: proposal_2, user: user) }
  let!(:contract_3) { create(:contract, proposal: proposal_3, user: user) }
  let!(:contract_4) { create(:contract, proposal: proposal_4, user: user) }
  let!(:contract_5) { create(:contract, proposal: proposal_6, user: user) }

end
