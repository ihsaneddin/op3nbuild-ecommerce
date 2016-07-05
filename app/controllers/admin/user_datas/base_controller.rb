class Admin::UserDatas::BaseController < Admin::BaseController
	before_action :verify_super_admin
end
