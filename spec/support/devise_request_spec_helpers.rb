module DeviseRequestSpecHelpers
  def sign_in(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: user.password
      }
    }
  end

  def sign_out
    delete destroy_user_session_path
  end
end

RSpec.configure do |config|
  config.include DeviseRequestSpecHelpers, type: :request
end