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
    col = md[2].to_i - 1
    row = 0
    # 'A'.ord #=> 65
    md[1].reverse.split('').each_with_index do |c, i|
      row += (c.ord - 64) * (26 ** i)
    end
    row -= 1
    begin
      cell = sheet.cell(col, row)
      cell.respond_to?(:value) ? cell.value : (cell || default_value)
    rescue => ex
      default_value
    end
  end
end
