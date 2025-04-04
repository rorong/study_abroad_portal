class ApplicationController < ActionController::Base
  include Pundit::Authorization
  
  # Prevent CSRF attacks by raising an exception
  protect_from_forgery with: :exception

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Authenticate user with Devise
  before_action :authenticate_user!

  # Rescue from Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
