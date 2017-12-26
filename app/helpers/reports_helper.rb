module ReportsHelper
  # UTF-8文字列をWindows-31Jに変換する
  # @param [String] utf8_str
  # @return [String] win31j_str
  def convert_to_windows31j(utf8_str)
    # Macのファイル名の文字コード対策
    utf8_str.encode!('UTF-8-MAC', 'UTF-8', invalid: :replace, undef: :replace, replace: '')
    utf8_str.encode!('UTF-8')

    # Windows-31Jに変換できるUTF-8文字列に変換する
    [
      %w(301C FF5E), # wave-dash
      %w(2212 FF0D), # full-width minus
      %w(00A2 FFE0), # cent as currency
      %w(00A3 FFE1), # lb(pound) as currency
      %w(00AC FFE2), # not in boolean algebra
      %w(2014 2015), # hyphen
      %w(2016 2225)  # double vertical lines
    ].each do |codes|
      utf8_str.gsub!(code_point_to_char(codes[0]), code_point_to_char(codes[1]))
    end
    utf8_str.encode('WINDOWS-31J')
  end

  def code_point_to_char(code_point)
    code_point.to_i(16).chr('UTF-8')
  end
end
