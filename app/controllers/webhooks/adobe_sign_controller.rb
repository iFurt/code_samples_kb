class Webhooks::AdobeSignController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:handle]

  def check
    respond_to_webhook
  end

  def handle
    respond_to_webhook { AdobeSign::HandleWebhookService.perform(params) }
  end

  private

  def respond_to_webhook(&block)
    # TODO need to check referrer as well!
    if request.headers['HTTP_X_ADOBESIGN_CLIENTID'] == ENV['ADOBE_SIGN_CLIENT_ID']
      yield if block_given?
      response.headers.merge!({ 'X-AdobeSign-ClientId' => ENV['ADOBE_SIGN_CLIENT_ID'] })
      render nothing: true, status: 200
    else
      render nothing: true, status: 404
    end
  end
end
