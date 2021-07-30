module LotsService
  class Clone
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      clone
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def clone
      execute_or_rollback do
        clone_lots!
      end
    end

    def clone_lots!
      # calls skip_cloning_validations so we wont validate the old dates
      deep_clone.skip_cloning_validations!
      deep_clone.draft!
      recalculate_quantity!
    end

    def deep_clone
      @deep_clone ||= bidding.deep_clone(options) do |original, kopy|
        kopy.parent_id = original.id if kopy.respond_to?(:parent_id)
        kopy.status = :draft if kopy.is_a? Lot
      end
    end

    def recalculate_quantity!
      RecalculateQuantityService.call!(covenant: bidding.covenant)
    end

    def options
      {
        include: associations_includes,
        skip_missing_associations: true,
        except: exceptions
      }
    end

    def associations_includes
      [
        {
          invites: invite_approved_lambda,
          lots: [:lot_group_items, lot_name_lambda],
        },
        :cooperative
      ]
    end

    def exceptions
      [
        :merged_minute_document_id,
        :edict_document_id,
        :spreadsheet_report_id,
        { lots: [:lot_group_items_count] }
      ]
    end

    def invite_approved_lambda
      { if: lambda{ |invite| invite.approved? } }
    end

    def lot_name_lambda
      { if: lambda{ |lot| lot.name == bidding_lot.name } }
    end

    def bidding_lot
      @bidding_lot ||= lot_proposal.lot
    end

    def lot_proposal
      @lot_proposal ||= proposal.lot_proposals.first
    end

    def bidding
      @bidding ||= proposal.bidding
    end
  end
end
