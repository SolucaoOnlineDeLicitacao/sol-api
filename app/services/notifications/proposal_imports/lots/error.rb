module Notifications
  class ProposalImports::Lots::Error < ProposalImports::Lots::Base

    def body_args
      [lot.name, lot_proposal_import.file.filename]
    end

  end
end
