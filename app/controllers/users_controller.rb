class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where(enrolled: true).order(id: :asc)
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "user_#{Time.zone.now.strftime('%Y%m%d')}.csv", type: :csv
      end
    end
  end

  def show
  end
end
