module Spreadsheet::Write
  class Strategy
    def self.decide(file_type)
      file_type == 'xls' ? Xls.new : Xlsx.new
    end
  end
end
