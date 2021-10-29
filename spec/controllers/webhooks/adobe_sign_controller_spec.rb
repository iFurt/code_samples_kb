require 'spec_helper'

RSpec.describe Webhooks::AdobeSignController do
  before do
    create(:company_w_account)
    allow(AdobeSign::HandleWebhookService).to receive(:perform)
  end

  describe '#check' do
    subject { get :check }

    context 'when headers contain HTTP_X_ADOBESIGN_CLIENTID key' do
      before { request.headers['HTTP_X_ADOBESIGN_CLIENTID'] = ENV['ADOBE_SIGN_CLIENT_ID'] }

      it 'sets X-AdobeSign-ClientId header' do
        expect(subject.headers['X-AdobeSign-ClientId']).to eq ENV['ADOBE_SIGN_CLIENT_ID']
      end

      it 'renders 200' do
        expect(subject.status).to eq 200
      end
    end

    context 'when headers do not contain HTTP_X_ADOBESIGN_CLIENTID key' do
      it 'renders 404' do
        expect(subject.status).to eq 404
      end
    end
  end

  describe '#handle' do
    let(:params) {{ 'some' => { 'adobe_sign' => 'params'}, 'controller' => 'webhooks/adobe_sign', 'action' => 'handle' }}
    subject { post :handle, params }

    context 'when headers contain HTTP_X_ADOBESIGN_CLIENTID key' do
      before { request.headers['HTTP_X_ADOBESIGN_CLIENTID'] = ENV['ADOBE_SIGN_CLIENT_ID'] }

      it 'calls AdobeSign::HandleWebhookService' do
        expect(AdobeSign::HandleWebhookService).to receive(:perform).with(params)
        subject
      end

      it 'sets X-AdobeSign-ClientId header' do
        expect(subject.headers['X-AdobeSign-ClientId']).to eq ENV['ADOBE_SIGN_CLIENT_ID']
      end

      it 'renders 200' do
        expect(subject.status).to eq 200
      end
    end

    context 'when headers do not contain HTTP_X_ADOBESIGN_CLIENTID key' do
      it 'renders 404' do
        expect(subject.status).to eq 404
      end
    end
  end
end
