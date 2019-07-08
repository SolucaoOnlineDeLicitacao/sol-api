module Administrator
  class ReportSerializer < ActiveModel::Serializer
    attributes :id, :admin_id, :admin_name, :report_type, :status, :url,
               :error_message, :error_backtrace, :created_at

    def admin_id
      object.admin.id
    end

    def admin_name
      object.admin.name
    end
  end
end
