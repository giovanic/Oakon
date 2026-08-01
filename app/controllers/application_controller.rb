class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def pundit_user
    current_admin_user
  end

  def user_not_authorized
    redirect_back fallback_location: admin_dashboard_path, alert: "Você não tem permissão para realizar esta ação."
  end

  def after_sign_in_path_for(resource)
    resource.is_a?(AdminUser) ? admin_dashboard_path : super
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_admin_user_session_path
  end
end
