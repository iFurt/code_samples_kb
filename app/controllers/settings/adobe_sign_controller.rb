class Settings::AdobeSignController < BaseSettingsController
  before_action :authorize_global_admin_user

  def get_access_token
    redirect_to AdobeSignOauthAccessToken.access_token_link
  end

  def handle_access_token
    if params[:code].present?
      adobe_sign_oauth_access_token = AdobeSignOauthAccessToken.take || AdobeSignOauthAccessToken.new
      adobe_sign_oauth_access_token.retreive_token!(params[:code])
      flash[:notice] = 'Adobe Sign authorized successfully'
    else
      flash[:alert] = "Adobe Sign authorization error: #{params[:error_description]}"
    end
    redirect_to integrations_settings_path
  end

  def revoke_access
    AdobeSignOauthAccessToken.take.destroy
    flash[:notice] = 'Adobe Sign access revoked'
    redirect_to :back
  end
end
