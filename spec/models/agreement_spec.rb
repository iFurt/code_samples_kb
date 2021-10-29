require 'spec_helper'

RSpec.describe Agreement, type: :model do
  it { should belong_to(:quotation) }
  it { should belong_to(:faria_rep_user).class_name('User') }
  it { should belong_to(:school_rep_contact_email).class_name('ContactEmail') }
  it { should have_one(:school_rep_contact).class_name('Person').through(:school_rep_contact_email).source(:contact) }

  let(:adobe_sign_agreement_id) { 'some_string_id' }
  let(:adobe_sign_transient_document_id) { 'id_of_adobe_sign_transient_document_id' }
  let(:account) { create(:account_w_companies) }
  let(:user) { create(:user, account: account)}
  let(:agreement) { create(:agreement, user: user, adobe_sign_agreement_id: adobe_sign_agreement_id, adobe_sign_transient_document_id: adobe_sign_transient_document_id) }

  describe '#link_to_signed_inside_adobe' do
    it 'returns link to Adobe Sign doc' do
      expected = [
        "https://secure.#{ENV['ADOBE_SIGN_SHARD_NAME']}.echosign.com",
        'public',
        'agreements',
        'view',
        agreement.adobe_sign_agreement_id
      ].join('/')

      expect(agreement.link_to_signed_inside_adobe).to eq expected
    end
  end

  describe '#send_for_sign!' do
    before do
      allow(AdobeSign::CreateTransientDocumentService).to receive(:perform)
      allow(AdobeSign::SendDocumentService).to receive(:perform)
    end

    context 'when adobe_sign_agreement_id is blank' do
      let(:adobe_sign_agreement_id) { nil }

      context 'and adobe_sign_transient_document_id is blank' do
        let(:adobe_sign_transient_document_id) { nil }

        it 'posts transient document and sends agreement' do
          expect(AdobeSign::CreateTransientDocumentService).to receive(:perform).with(agreement)
          expect(AdobeSign::SendDocumentService).to receive(:perform).with(agreement, nil)

          agreement.send_for_sign!
        end
      end

      context 'and adobe_sign_transient_document_id is present' do
        it 'only sends agreement' do
          expect(AdobeSign::CreateTransientDocumentService).not_to receive(:perform)
          expect(AdobeSign::SendDocumentService).to receive(:perform).with(agreement, nil)

          agreement.send_for_sign!
        end
      end
    end

    context 'when adobe_sign_agreement_id is present' do
      it 'raises error' do
        expect { agreement.send_for_sign! }.to raise_error
      end
    end
  end

  describe '#regenerate!' do
    before { allow(AdobeSign::AgreementCancelService).to receive(:perform) }

    context 'when adobe_sign_agreement_id is blank' do
      let(:adobe_sign_agreement_id) { nil }

      it 'does not cancel agreement' do
        expect(AdobeSign::AgreementCancelService).not_to receive(:perform)

        agreement.regenerate!
      end
    end

    context 'when adobe_sign_agreement_id is present' do
      it 'cancels agreement' do
        expect(AdobeSign::AgreementCancelService).to receive(:perform)

        expect { agreement.regenerate! }.to change { agreement.adobe_sign_agreement_id }.from(adobe_sign_agreement_id).to(nil)
      end
    end
  end
end
