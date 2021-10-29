class AgreementReminderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(agreement_id)
    agreement = Agreement.find(agreement_id)

    AdobeSign::AgreementReminderService.perform(agreement)
  end
end
