module RedminePretend
  module ApplicationControllerPatch
    extend ActiveSupport::Concern

    included do
      helper PretendHelper
      helper_method :real_user
    end

    def real_user
      @real_user ||= User.find_by_id(User.active.find(session[:real_user_id]))
    end

    def pretending?
      session[:real_user_id].present?
    end
  end
end

unless ApplicationController.included_modules.include?(RedminePretend::ApplicationControllerPatch)
  ApplicationController.include RedminePretend::ApplicationControllerPatch
end
