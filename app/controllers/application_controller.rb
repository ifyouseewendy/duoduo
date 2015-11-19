class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

   def user_not_authorized(exception)
     if exception.message == 'locked'
       flash[:error] = "用户<#{current_admin_user.name}>已被锁定"
       sign_out current_admin_user
       redirect_to '/login'
     else
       policy_name = exception.policy.class.to_s.underscore

       flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
       redirect_to(request.referrer || root_path)
     end
   end
end
