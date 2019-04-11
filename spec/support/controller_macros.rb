module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in FactoryGirl.create(:admin) # Using factory bot as an example
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in user
    end
  end


  # def login_user
  #   before(:each) do
  #     controller.stub(:authenticate_user!).and_return true
  #     @request.env["devise.mapping"] = Devise.mappings[:user]
  #     sign_in FactoryGirl.create(:user)
  #   end
  # end
end