# PayRb

🚧 UNDER DEVELOPMENT 🚧 

Ruby client for bank APIs.

A Ruby wrapper for banks' REST API that provides a simple interface for managing banking operations. It support banks
that have [this kind of API](https://gateway.jcc.com.cy/developer/en/integration/api/rest/rest.html).

It currently supports [JCC](https://gateway.jcc.com.cy/developer/en/integration/api/rest/rest.html) and [DSK](https://uat.dskbank.bg/sandbox/en/integration/api/rest/rest.html) banks.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add pay_rb
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install pay_rb
```

## Usage

```ruby
require 'pay_rb'

# Initialize the client
# Requires the following parameters:
# - username: Provided by Bank
# - password: Provided by Bank
# - environment: The environment to use (uat or production)
# - bank: The bank to use (dsk, jcc)
client = PayRb::Client.new(username: 'username', password: 'password', environment: 'uat', bank: 'dsk')

# Register a new payment

# The register_payment method requires the following parameters:
# - amount: The amount of the payment
# - return_url: The URL to redirect the user to after the payment is completed
# - description: The description of the payment
# - order_number: The order number

response = client.register_payment(amount: 100, return_url: 'https://example.com', description: 'Test payment', orderNumber: '123')
redirect_url = response['formUrl']

# Get order status
# The get_order_status method requires the following parameters:
# - order_id: The order ID

response = client.get_order_status('123')

# Refund a payment
# The refund_payment method requires the following parameters:
# - amount: The amount of the refund in smaller unit
# - order_id: The order ID

response = client.refund_payment(amount: 100, order_id: '123')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kiriakosv/pay_rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
