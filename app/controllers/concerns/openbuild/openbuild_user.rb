module Openbuild
  module OpenbuildUser
    extend ActiveSupport::Concern


    protected
      def is_openbuild_user?
        @openbuild_user = nil
        if params[:type].present?
          @openbuild_user = ::User.get_existing_openbuild_user authentication_token: params[:authentication_token], type: params[:type]
        end
        if @openbuild_user.nil?
          respond_to do |f|
            f.html{
              redirect_to login_url, :alert => I18n.t('login_failure')
            }
            f.json {
              render json: {error: "Not found"}, status: 404
            }
          end
        end
      end

      def user
        return @user if @user
        @user = ::User.find_by_access_token @openbuild_user.access_token
        raise ActiveRecord::RecordNotFound unless @user
        @user
      end

  end
end