module BiddingsService::Upload::All::Concerns
  module XlsxRows
    include Constants

    def all_rows
      all_rows = []
      sheet.each do |row|
        lines = []
        row && row.cells.each do |cell|
          val = cell && cell.value
          lines.push(val)
        end

        all_rows.push(lines)
      end

      all_rows[from_line_three..to_end].reject{ |row| row.compact.empty? }
    end
  end
end
