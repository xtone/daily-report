module SpreadsheetReadable
  extend ActiveSupport::Concern

  private

  # Spreadsheetのセルの値を、座標を指定して取得する
  # @param [Spreadsheet::Worksheet] sheet
  # @param [String] address セルの座標。 ex) 'S17', 'AA5'
  # @param [String | Integer | Float] default_value セルが空だったときに返す値
  # @return [String | Integer | Float | nil] セルに入っている値
  def read(sheet, address, default_value = nil)
    md = address.match(/\A([A-Z]+)(\d+)\z/)
    row = md[2].to_i
    col = md[1]
    begin
      logger.debug "value = #{sheet.cell(row, col)}"
      sheet.cell(row, col) || default_value
    rescue StandardError => e
      logger.debug e.message
      logger.debug e.backtrace.join("\n")
      raise e
    end
  end
end
