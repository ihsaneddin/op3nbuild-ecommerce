class API::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  #before_action
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  include ::Openbuild::OpenbuildUser

  before_action :is_openbuild_user?

  #respond_to :json

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: 'Record not found', status: 404
  end
end
