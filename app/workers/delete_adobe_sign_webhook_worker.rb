class DeleteAdobeSignWebhookWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(agreement_id)
    agreement = Agreement.find(agreement_id)

    AdobeSign::DeleteWebhookService.perform(agreement)
  end
end
