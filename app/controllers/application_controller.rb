class ApplicationController < ActionController::Base
  before_filter :require_login, unless: :devise_controller?

  # force_ssl

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ## Devise filters
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_me!
  
  # for i18L
  before_action :set_locale

  # before_action do
  #   resource = controller_name.singularize.to_sym
  #   method = "#{resource}_params"
  #   params[resource] &&= send(method) if respond_to?(method, true)
  # end

  #cancancan access denied
  rescue_from CanCan::AccessDenied, with: :access_denied

  def authenticate_me!
    # Skip auth if you are trying to log in
    return true if controller_name.downcase == "welcome"
    authenticate_user!
  end

  def access_denied
    render file: 'public/403.html', status: 403
  end

  private
  def set_locale
    requested_locale = params[:locale] || user_preferred_language || extract_locale_from_accept_language_header || I18n.default_locale
    requested_locale = I18n.default_locale unless I18n.available_locales.include? requested_locale.try(:to_sym)
    I18n.locale = requested_locale
  end 

  def extract_locale_from_accept_language_header
    if request.env['HTTP_ACCEPT_LANGUAGE']
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    else
      nil
    end
  end

  def user_preferred_language
    current_user.try(:preferred_language)
  end

  protected

  def require_login
    unless current_user
      session[:portal] = url_for(params)
      redirect_to new_user_session_url
    end
  end

  def after_sign_in_path_for(resource)
    session[:portal] || request.referer || root_path
  end

  def authenticate_user_from_token!
    user_token = params[:user_token].presence
    user = user_token && User.find_by_authentication_token(user_token.to_s)
    if user
      sign_in user, store: false
    end
  end

end
