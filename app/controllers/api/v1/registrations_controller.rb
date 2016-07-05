class Api::V1::RegistrationsController < API::BaseController

  before_action :existed_user

  def create
    @user = User.new(allowed_params) unless @user
    @user.trial = @openbuild_user.trial
    if @user.save
      set_contractor if is_profesional?
      render json: {:email => @user.email, first_name: @user.first_name, last_name: @user.last_name, :access_token => @user.access_token, permalink: @user.slug}, status: 201
    else
      render :json => @user.errors.to_json, status: 422
    end
  end

  protected

    def allowed_params
      params.require(:user).permit(:password, :password_confirmation, :first_name, :last_name, :email, :company_name)
    end
    
    def set_contractor
      @user.roles << Role.find_by_name(Role::CONTRACTOR) rescue nil
      @user.roles << Role.find_by_name(Role::ADMIN) #temporary
    end

    def set_trial_account
      if @user && @openbuild_user
        @user.account_id = Account.trial.id if @openbuild_user.trial
      end
    end

    def existed_user
      @user ||= User.find_by email: allowed_params[:email]      
    end 

    def is_profesional?
      params[:type].eql? "Professional"
    end  

end
