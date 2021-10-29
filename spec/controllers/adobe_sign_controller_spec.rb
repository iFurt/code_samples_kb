require 'spec_helper'

RSpec.describe AdobeSignController do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account)}
  let(:agreement) { create(:agreement, user: user) }

  before do
    allow(controller).to receive(:authenticate_user!)
    allow(controller).to receive(:current_user).and_return(user)
    allow_any_instance_of(Agreement).to receive(:send_via_adobe_sign)
    allow(AgreementReminderWorker).to receive(:perform_async)
  end

  describe '#send_agreement' do
    let(:params) {{ id: agreement.id }}
    subject { post :send_agreement, params }

    context 'when user is not eligable to send agreements' do
      before { allow(user).to receive(:adobe_sign_permitted?).and_return(false) }

      it 'redirects to root_path' do
        expect(agreement).not_to receive(:send_for_sign!)
        expect(subject).to redirect_to root_path
      end
    end

    context 'when user is eligable to send agreements' do
      before { allow(user).to receive(:adobe_sign_permitted?).and_return(true) }

      it 'changes agreement status' do
        expect { subject }.to change { agreement.reload.status }.from('generated').to('sent_for_sign')
      end

      it 'redirects to agreement path' do
        expect(subject).to redirect_to organization_agreement_path(organization_id: agreement.organization_id, id: agreement.id)
      end
    end
  end

  describe '#send_agreement_reminder' do
    let(:params) {{ id: agreement.id }}
    subject { post :send_agreement_reminder, params }

    context 'when user is not eligable to send agreement reminders' do
      before { allow(user).to receive(:adobe_sign_permitted?).and_return(false) }

      it 'redirects to root_path' do
        expect(agreement).not_to receive(:send_for_sign!)
        expect(subject).to redirect_to root_path
      end
    end
  end
end
