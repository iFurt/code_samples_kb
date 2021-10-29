require 'spec_helper'

RSpec.describe Settings::XeroController do
  let(:account) { create(:account_w_companies) }
  let(:user) { create(:user, account: account, roles: roles)}
  let(:agreement) { create(:agreement, user: user) }

  before do
    sign_in user
    allow_any_instance_of(XeroOauthAccessToken).to receive(:retreive_token!)
    create(:xero_oauth_access_token)
    request.env["HTTP_REFERER"] = root_path
    allow(Xero::BindTenantIdWithCompanyService).to receive(:perform)
  end

  describe '#get_access_token' do
    subject { get :get_access_token }

    context 'when user is global admin' do
      let(:roles) { [:admin, :global_admin] }

      it 'redirects to access token link of Adobe Sing' do
        expect(subject).to redirect_to XeroOauthAccessToken.access_token_link
      end
    end

    context 'when user is not global admin' do
      let(:roles) { [] }

      it 'renders Not Found' do
        expect(subject.status).to eq(404)
      end
    end
  end

  describe '#handle_access_token' do
    let(:code) { SecureRandom.hex }
    subject { get :handle_access_token, code: code }

    context 'when user is global admin' do
      let(:roles) { [:admin, :global_admin] }

      it 'calls #retreive_token!' do
        expect_any_instance_of(XeroOauthAccessToken).to receive(:retreive_token!).with(code)
        subject
      end

      it 'calls binds tenant ids' do
        expect(Xero::BindTenantIdWithCompanyService).to receive(:perform)
        subject
      end

      it 'redirects to integration settings' do
        expect(subject).to redirect_to integrations_settings_path
      end
    end

    context 'when user is not global admin' do
      let(:roles) { [] }

      it 'renders Not Found' do
        expect(subject.status).to eq(404)
      end
    end
  end

  describe '#revoke_access' do
    subject { delete :revoke_access }

    context 'when user is global admin' do
      let(:roles) { [:admin, :global_admin] }

      xit 'deletes oauth token' do
        # TODO implement functionality
        expect { subject }.to change { XeroOauthAccessToken.count }.from(1).to(0)
      end
    end

    context 'when user is not global admin' do
      let(:roles) { [] }

      it 'renders Not Found' do
        expect(subject.status).to eq(404)
      end

      it 'does not delete XeroOauthAccessToken' do
        expect(XeroOauthAccessToken.count).to eq 1
        expect { subject }.not_to change { XeroOauthAccessToken.count }
      end
    end
  end
end
