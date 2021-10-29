require 'spec_helper'

RSpec.describe Settings::AdobeSignController do
  let(:account) { create(:account_w_companies) }
  let(:user) { create(:user, account: account, roles: roles)}
  let(:agreement) { create(:agreement, user: user) }

  before do
    sign_in user
    allow_any_instance_of(AdobeSignOauthAccessToken).to receive(:retreive_token!)
    create(:adobe_sign_oauth_access_token)
    request.env["HTTP_REFERER"] = root_path
  end

  describe '#get_access_token' do
    subject { get :get_access_token }

    context 'when user is global admin' do
      let(:roles) { [:admin, :global_admin] }

      it 'redirects to access token link of Adobe Sing' do
        expect(subject).to redirect_to AdobeSignOauthAccessToken.access_token_link
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
        expect_any_instance_of(AdobeSignOauthAccessToken).to receive(:retreive_token!).with(code)
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

      it 'deletes oauth token' do
        expect { subject }.to change { AdobeSignOauthAccessToken.count }.from(1).to(0)
      end
    end

    context 'when user is not global admin' do
      let(:roles) { [] }

      it 'renders Not Found' do
        expect(subject.status).to eq(404)
      end

      it 'does not delete AdobeSignOauthAccessToken' do
        expect(AdobeSignOauthAccessToken.count).to eq 1
        expect { subject }.not_to change { AdobeSignOauthAccessToken.count }
      end
    end
  end
end
