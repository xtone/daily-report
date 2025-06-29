module Reports
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  # params[:date]のStringを、Dateに変換する
  # @return [Date] 変換できなければnilを返す
  def get_date
    return nil unless params[:date].present?

    /\A(\d{4})(\d{2})\Z/.match(params[:date]) do |m|
      time = begin
        Time.zone.local(m[1], m[2])
      rescue StandardError
        nil
      end
      time&.to_date
    end
  end

  # datetime_select のFormヘルパーのパラメータをDateに変換する
  # @param [Symbol] object_name
  # @param [Symbol] method
  # @return [Date]
  def params_to_date(object_name, method)
    Date.new(
      params[object_name]["#{method}(1i)"].to_i,
      params[object_name]["#{method}(2i)"].to_i,
      params[object_name]["#{method}(3i)"].to_i
    )
  end
end
