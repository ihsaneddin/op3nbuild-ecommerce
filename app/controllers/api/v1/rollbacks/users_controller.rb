class Api::V1::Rollbacks::UsersController < API::BaseController

  before_action :user

  def trial
    if @user.rollback_trial @openbuild_user
       render json: {user: { status: 'tril rollback succeeded' }}.to_json, status: 200
    else
      render json: {error: "An error has ocurred"}.to_json, status: 422
    end
  end

  protected
    def user_params
      params.require(:user).permit(:first_name, :last_name, :company_name)
    end

end
