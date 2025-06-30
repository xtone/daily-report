class SjisConvertibleValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    begin
      # UTF-8からSJISへの変換を試行
      value.encode('Shift_JIS')
    rescue Encoding::UndefinedConversionError => e
      # 変換できない文字を特定
      invalid_char = e.error_char
      record.errors.add(
        attribute, 
        options[:message] || "に Shift_JIS に変換できない文字「#{invalid_char}」が含まれています。別の文字に置き換えてください。"
      )
    end
  end
end