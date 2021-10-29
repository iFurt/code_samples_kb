require 'spec_helper'

describe AdobeSign::CreateTransientDocumentService do
  let(:agreement) { create(:agreement, adobe_sign_transient_document_id: nil) }
  let(:transient_document_id) { 'id_of_transient_document_id' }
  let(:response_body) { { 'transientDocumentId' => transient_document_id }.to_json }
  subject { described_class.perform(agreement) }

  before do
    create(:account)
    create(:adobe_sign_oauth_access_token, user: nil)
    stub_request(:post, "#{described_class::ADOBE_SIGN_HOST}#{described_class::URL}").to_return(body: response_body, status: response_status)
    allow_any_instance_of(described_class).to receive(:body)
  end

  describe '#perform' do
    context 'when response is successful' do
      let(:response_status) { 200 }

      it 'updates agreement`s adobe_sign_transient_document_id' do
        expect { subject }.to change { agreement.adobe_sign_transient_document_id }.from(nil).to(transient_document_id)
      end

      it 'makes request' do
        subject
        expect(WebMock).to have_requested(:post, "#{described_class::ADOBE_SIGN_HOST}#{described_class::URL}")
      end
    end

    context 'when response is not successful' do
      let(:response_status) { 400 }

      it 'raises error' do
        expect { subject }.to raise_error
      end
    end
  end
end
