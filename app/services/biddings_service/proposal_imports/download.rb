module BiddingsService::ProposalImports
  class Download
    include Call::Methods

    attr_accessor :bidding

    def initialize(*args)
      super
      @bidding = Bidding.find(bidding_id)
    end

    def main_method
      update_bidding_proposal_import_file!
    end

    private

    def update_bidding_proposal_import_file!
      bidding.update!(proposal_import_file: proposal_import_file)
    end

    def proposal_import_file
      File.open(download_all_file_path)
    end

    def download_all_file_path
      BiddingsService::Download::All.call(bidding: bidding, file_type: 'xlsx')
    end
  end
end
