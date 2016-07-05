module Loggedable
  extend ActiveSupport::Concern

  ###  Authlogic helper methods
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def current_user_id
    return @current_user_id if defined?(@current_user_id)
    @current_user_id = current_user_session && current_user_session.record && current_user_session.record.id
  end

  protected

    ### Call this method after session is created
    def logging_in!
      @user_session.record.logging_in! if @user_session.record
    end

    def require_login
      verify_user_is_logged_in do
        if !current_user 
          session[:return_to] = shopping_orders_url
          redirect_to root_path, notice: "You must register first on openbuild.co"
          #redirect_to( login_url() ) and return
        end
      end
    end

    def verify_admin
      verify_user_is_logged_in do
        redirect_to root_url if !current_user || !current_user.admin?
      end
    end

    def verify_super_admin
      verify_user_is_logged_in do
        if current_user
          raise CanCan::AccessDenied.new("Not authorized!") unless current_user.super_admin?
        else
          raise CanCan::AccessDenied.new("Not authorized!")
        end
      end
    end

    def verify_user_is_logged_in
      if current_user.present? && !current_user.is_logged_in
        destroy_session
        redirect_to root_url, :notice => "You must login first."
      else
        yield
      end
    end

    def destroy_session
      current_user_session.destroy
      reset_session
      cookies.delete(:hadean_uid)
    end

end
