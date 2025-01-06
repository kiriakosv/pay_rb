module PayRb
  class Client
    BASE_URLS = {
      dsk: {
        uat: 'https://uat.dskbank.bg',
        production: 'https://epg.dskbank.bg'
      },
      jcc: {
        uat: 'https://gateway-test.jcc.com.cy',
        production: 'https://gateway.jcc.com.cy'
      }
    }.freeze

    def initialize(username:, password:, environment:, bank:)
      @username = username
      @password = password
      @environment = environment.to_sym
      @bank = bank.to_sym

      validate_environment
      validate_bank

      @base_url = BASE_URLS[@bank][@environment]
    end

    def payment_registration(params)
      camelized_params = params.transform_keys { |key| key.to_s.camelize(:lower) }

      response = connection.post('/payment/rest/register.do') do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(default_params.merge(camelized_params))
      end

      JSON.parse(response.body)
    end

    def get_order_status(order_id)
      params = { orderId: order_id }

      response = connection.post('/payment/rest/getOrderStatus.do') do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(default_params.merge(params))
      end

      JSON.parse(response.body)
    end

    def refund_payment(params)
      camelized_params = params.transform_keys { |key| key.to_s.camelize(:lower) }

      response = connection.post('/payment/rest/refund.do') do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(default_params.merge(camelized_params))
      end

      JSON.parse(response.body)
    end

    private

    attr_reader :username, :password, :environment, :bank, :base_url

    ALLOWED_ENVIRONMENTS = BASE_URLS.values.flat_map(&:keys).uniq.freeze
    private_constant :ALLOWED_ENVIRONMENTS

    ALLOWED_BANKS = BASE_URLS.keys.freeze
    private_constant :ALLOWED_BANKS

    def validate_environment
      return if ALLOWED_ENVIRONMENTS.include?(environment)

      raise(
        ArgumentError,
        "Invalid environment: #{environment}. Allowed environments: #{ALLOWED_ENVIRONMENTS.join(", ")}"
      )
    end

    def validate_bank
      return if ALLOWED_BANKS.include?(bank)

      raise(
        ArgumentError,
        "Invalid bank: #{bank}. Allowed banks: #{ALLOWED_BANKS.join(", ")}"
      )
    end

    def connection
      @connection ||= Faraday.new(url: base_url, headers: default_headers) do |conn|
        conn.adapter Faraday.default_adapter
        conn.response :json
        conn.response :raise_error
        conn.request :url_encoded
      end
    end

    def default_headers
      {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    end

    def default_params
      {
        'userName' => username,
        'password' => password
      }
    end
  end
end
