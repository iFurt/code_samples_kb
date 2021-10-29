require 'spec_helper'

describe AdobeSign::HandleWebhookService do
  let(:agreement_adobe_id) { 'id_of_agreement_adobe_id' }
  let!(:account) { create(:account) }
  let!(:agreement) { create(:agreement, status: :sent_for_sign, adobe_sign_agreement_id: agreement_adobe_id) }
  let(:response_body) do
    {
      'adobe_sign' => {
        'event' => status,
        'agreement' => {
          'id' => agreement_adobe_id
        }
      }
    }
  end
  subject { described_class.perform(response_body) }

  before do
    allow(DownloadSignedAgreementWorker).to receive(:perform_async)
  end

  describe '#perform' do
    context 'when response is agreement workflow completed' do
      let(:status) { described_class::WH_WORKFLOW_COMPLETED_STATUS }

      it 'performs agreement sign' do
        expect(DownloadSignedAgreementWorker).to receive(:perform_async).with(agreement.id)
        subject
        expect(agreement.reload.status).to eq('signed')
      end
    end

    context 'when response is agreement recalled' do
      let(:status) { described_class::WH_CANCELLED_STATUS }

      it 'performs agreement decline' do
        expect(DownloadSignedAgreementWorker).not_to receive(:perform_async)
        subject
        expect(agreement.reload.status).to eq('declined')
      end
    end

    context 'when response status is not recognized' do
      let(:status) { 'Not recognized' }

      it 'does not change status' do
        expect(DownloadSignedAgreementWorker).not_to receive(:perform_async)
        subject
        expect(agreement.reload.status).to eq('sent_for_sign')
      end
    end
  end
end
