module Administrator
  class ReportsController < AdminController
    include CrudController

    load_and_authorize_resource

    PERMITTED_PARAMS = [:report_type].freeze

    expose :reports, -> { find_reports }
    expose :report

    private

    def created?
      report_service.async_call
      report = report_service.report
      report.try(:valid?)
    end

    def resource
      report
    end

    def resources
      reports
    end

    def default_sort_scope
      resources
    end

    def find_reports
      Report.where(filter_params).accessible_by(current_ability)
    end

    def report_params
      params.require(:report).permit(*PERMITTED_PARAMS)
    end

    def report_service
      @report_service ||=
        ReportsService::Create.new(
          admin: current_user, report_type: report_params[:report_type]
        )
    end

    def filter_params
      { report_type: report_type, status: status }.delete_if { |_, value| value.blank? }
    end

    def report_type
      params['report_type']
    end

    def status
      params['status']
    end
  end
end
