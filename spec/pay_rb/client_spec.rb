# frozen_string_literal: true

require 'rspec'
require 'webmock/rspec'

RSpec.describe 'PayRb::Client' do
  let(:client) { PayRb::Client.new(username: 'username', password: 'password', environment: 'uat', bank: 'dsk') }

  describe 'initialization' do
    subject { client }

    it 'accepts username, password and environment and bank as arguments' do
      expect(subject).to be_a(PayRb::Client)

      expect(subject.instance_variable_get(:@username)).to eq('username')
      expect(subject.instance_variable_get(:@password)).to eq('password')
      expect(subject.instance_variable_get(:@environment)).to eq(:uat)
      expect(subject.instance_variable_get(:@bank)).to eq(:dsk)
    end

    it 'correctly sets base_url based on environment and bank combination' do
      expect(subject.instance_variable_get(:@base_url)).to eq('https://uat.dskbank.bg')
    end

    it 'validates environment' do
      expect { PayRb::Client.new(username: 'username', password: 'password', environment: 'invalid', bank: 'dsk') }.to raise_error(ArgumentError)
    end

    it 'validates bank' do
      expect { PayRb::Client.new(username: 'username', password: 'password', environment: 'uat', bank: 'invalid') }.to raise_error(ArgumentError)
    end
  end

  describe '#payment_registration' do
    subject { client.payment_registration(params) }

    let(:params) do
      {
        amount: 100,
        return_url: 'https://example.com/return',
        description: 'Test payment',
        order_number: '123'
      }
    end

    before do
      stub_request(:post, 'https://uat.dskbank.bg/payment/rest/register.do').
        with(
          body: {
            'amount' => '100',
            'description' => 'Test payment',
            'orderNumber' => '123',
            'password' => 'password',
            'returnUrl' => 'https://example.com/return',
            'userName' => 'username'
          },
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/x-www-form-urlencoded',
            'User-Agent' => 'Faraday v2.12.2'
          }
        ).to_return(
          status: 200,
          body: {
            orderId: '351435f6-d791-74a1-91d7-a4a62eadc91b',
            formUrl: 'https://form.url'
          }.to_json
      )
    end

    context 'when request is successful' do
      it 'returns parsed response body' do
        expect(subject).to eq(
          'orderId' => '351435f6-d791-74a1-91d7-a4a62eadc91b',
          'formUrl' => 'https://form.url'
        )
      end
    end

    context 'when request is unsuccessful' do
      before do
        stub_request(:post, 'https://uat.dskbank.bg/payment/rest/register.do').
          to_return(
            status: 401,
            body: 'Internal Server Error'
        )
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Faraday::UnauthorizedError)
      end
    end
  end

  describe '#get_order_status' do
    subject { client.get_order_status('abc-123') }

    before do
      stub_request(:post, 'https://uat.dskbank.bg/payment/rest/getOrderStatus.do').
        with(
          body: {
            'orderId' => 'abc-123',
            'password' => 'password',
            'userName' => 'username'
          },
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/x-www-form-urlencoded',
            'User-Agent' => 'Faraday v2.12.2'
          }
        ).to_return(
          status: 200,
          body: {
            currency: '975',
            authCode: '3',
            errorCode: '2',
            orderStatus: '1',
            orderNumber: '293933',
            amount: '100',
            orderId: '351435f6-d791-74a1-91d7-a4a62eadc91b',
            pan: '123456******3456'
          }.to_json
      )
    end

    context 'when request is successful' do
      it 'returns parsed response body' do
        expect(subject).to eq(
          'currency' => '975',
          'authCode' => '3',
          'errorCode' => '2',
          'orderStatus' => '1',
          'orderNumber' => '293933',
          'amount' => '100',
          'orderId' => '351435f6-d791-74a1-91d7-a4a62eadc91b',
          'pan' => '123456******3456'
        )
      end
    end

    context 'when request is unsuccessful' do
      before do
        stub_request(:post, 'https://uat.dskbank.bg/payment/rest/getOrderStatus.do').
          to_return(
            status: 401,
            body: 'Internal Server Error'
        )
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Faraday::UnauthorizedError)
      end
    end
  end

  describe '#refund_payment' do
    subject { client.refund_payment(params) }

    let(:params) do
      {
        amount: 100,
        order_id: 'abc123'
      }
    end

    before do
      stub_request(:post, 'https://uat.dskbank.bg/payment/rest/refund.do').
        with(
          body: {
            'amount' => '100',
            'orderId' => 'abc123',
            'password' => 'password',
            'userName' => 'username'
          },
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/x-www-form-urlencoded',
            'User-Agent' => 'Faraday v2.12.2'
          }
        ).to_return(
        status: 200,
        body: response_body.to_json
      )
    end

    context 'when request is successful' do
      let(:response_body) do
        {
          'errorCode' => '0',
          'errorMessage' => 'Success'
        }
      end

      it 'returns parsed response body' do
        expect(subject).to eq(
                             'errorCode' => '0',
                             'errorMessage' => 'Success'
                           )
      end
    end

    context 'when request is unsuccessful' do
      let(:response_body) do
        {
          'errorCode' => '1',
          'errorMessage' => 'Invalid order id'
        }
      end

      it 'returns parsed response body' do
        expect(subject).to eq(
                             'errorCode' => '1',
                             'errorMessage' => 'Invalid order id'
                           )
      end
    end
  end
end
