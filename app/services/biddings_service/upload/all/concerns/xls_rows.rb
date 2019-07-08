module BiddingsService::Upload::All::Concerns
  module XlsRows
    include Constants

    def all_rows
      sheet.rows[from_line_three..to_end].reject{ |row| row.compact.empty? }
    end
  end
end
