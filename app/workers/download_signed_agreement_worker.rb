class DownloadSignedAgreementWorker
  include Sidekiq::Worker

  def perform(agreement_id)
    agreement = Agreement.find(agreement_id)

    AdobeSign::DownloadSignedAgreementService.perform(agreement)
  end
end
