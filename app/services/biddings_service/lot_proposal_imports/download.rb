module BiddingsService::LotProposalImports
  class Download
    include Call::Methods

    attr_accessor :bidding, :lot

    def initialize(*args)
      super
      @bidding = Bidding.find(bidding_id)
      @lot = bidding.lots.find(lot_id)
    end

    def main_method
      update_lot_proposal_import_file!
    end

    private

    def update_lot_proposal_import_file!
      lot.update!(lot_proposal_import_file: lot_proposal_import_file)
    end

    def lot_proposal_import_file
      File.open(download_lot_file_path)
    end

    def download_lot_file_path
      BiddingsService::Download::Lot.call(bidding: bidding, lot: lot, file_type: 'xlsx')
    end
  end
end
