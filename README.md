# cased-ruby

A Cased client for Ruby applications in your organization to control and monitor the access of information within your organization.

## Overview

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Cased CLI](#cased-cli)
    - [Starting an approval workflow](#starting-an-approval-workflow)
  - [Audit trails](#audit-trails)
    - [Publishing events to Cased](#publishing-events-to-cased)
    - [Retrieving events from a Cased audit trail](#retrieving-events-from-a-cased-audit-trail)
    - [Retrieving events from multiple Cased audit trails](#retrieving-events-from-multiple-cased-audit-trails)
    - [Exporting events](#exporting-events)
    - [Masking & filtering sensitive information](#masking--filtering-sensitive-information)
    - [Disable publishing events](#disable-publishing-events)
    - [Context](#context)
    - [Testing](#testing)
- [Customizing cased-ruby](#customizing-cased-ruby)
- [Contributing](#contributing)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cased-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cased-ruby

## Configuration

All configuration options available in cased-ruby are available to be configured by an environment variable or manually.

```ruby
Cased.configure do |config|
  # CASED_POLICY_KEY=policy_live_1dQpY5JliYgHSkEntAbMVzuOROh
  config.policy_key = 'policy_live_1dQpY5JliYgHSkEntAbMVzuOROh'

  # CASED_USERS_POLICY_KEY=policy_live_1dQpY8bBgEwdpmdpVrrtDzMX4fH
  # CASED_ORGANIZATIONS_POLICY_KEY=policy_live_1dSHQRurWX8JMYMbkRdfzVoo62d
  config.policy_keys = {
    users: 'policy_live_1dQpY8bBgEwdpmdpVrrtDzMX4fH',
    organizations: 'policy_live_1dSHQRurWX8JMYMbkRdfzVoo62d',
  }

  # CASED_PUBLISH_KEY=publish_live_1dQpY1jKB48kBd3418PjAotmEwA
  config.publish_key = 'publish_live_1dQpY1jKB48kBd3418PjAotmEwA'

  # CASED_PUBLISH_URL=https://publish.cased.com
  config.publish_url = 'https://publish.cased.com'

  # CASED_URL=https://app.cased.com
  config.url = 'https://app.cased.com'

  # CASED_API_URL=https://api.cased.com
  config.api_url = 'https://api.cased.com'

  # CASED_RAISE_ON_ERRORS=1
  config.raise_on_errors = false

  # CASED_SILENCE=1
  config.silence = false

  # CASED_HTTP_OPEN_TIMEOUT=5
  config.http_open_timeout = 5

  # CASED_HTTP_READ_TIMEOUT=10
  config.http_read_timeout = 10
end
```

## Usage

### Cased CLI

#### Starting an approval workflow

To start an approval workflow you must first obtain your application key and the
user token for who is requesting access.

```ruby
Cased.configure do |config|
  config.guard_application_key = 'guard_application_1pG43HF3aRHjNTTm10zzu0tngBO'
end

authentication = Cased::CLI::Authentication.new(token: 'user_1pG43D1AzTjLR8XWJHj8B3aNZ4Y')
session = Cased::CLI::Session.new(
  authentication: authentication,
  reason: 'I need export our GitHub issues.',
  metadata: {
    organization: 'GitHub',
  },
)

if session.create && session.approved?
  github.issues.each do |issue|
    puts issue.title
  end
else
  puts 'Unauthorized to export GitHub issues.'
end
```

If you do not have the user token you can always request it interactively.
[Cased::CLI::Identity#identify](https://github.com/cased/cased-ruby/blob/3b0c8ebd37ba7deb83236be7dba4d52c74d7e4e5/lib/cased/cli/identity.rb#L10-L21)
is a blocking operation prompting the user to visit Cased to identify
themselves, returning their user token upon identifying themselves which can be
used to start your session.

```ruby
Cased.configure do |config|
  config.guard_application_key = 'guard_application_1pG43HF3aRHjNTTm10zzu0tngBO'
end

authentication = Cased::CLI::Authentication.new
identity = Cased::CLI::Identity.new
authentication.token = identity.identify

session = Cased::CLI::Session.new(
  authentication: authentication,
  reason: 'I need export our GitHub issues.',
  metadata: {
    organization: 'GitHub',
  },
)

if session.create && session.approved?
  github.issues.each do |issue|
    puts issue.title
  end
else
  puts 'Unauthorized to export GitHub issues.'
end
```

### Audit trails

#### Publishing events to Cased

There are two ways to publish your first Cased event.

**Manually**

```ruby
require 'cased-ruby'

Cased.configure do |config|
  config.publish_key = 'publish_live_1dQpY1jKB48kBd3418PjAotmEwA'
end

Cased.publish(
  action: 'credit_card.charge',
  amount: 2000,
  currency: 'usd',
  source: 'tok_amex',
  description: 'My First Test Charge (created for API docs)',
  credit_card_id: 'card_1dQpXqQwXxsQs9sohN9HrzRAV6y',
)
```

**Cased::Model**

`cased-ruby` provides a class mixin that gives you a framework to publish events.

```ruby
require 'cased-ruby'

Cased.configure do |config|
  config.publish_key = 'publish_live_1dQpY1jKB48kBd3418PjAotmEwA'
end

class CreditCard
  include Cased::Model

  def initialize(amount:, currency:, source:, description:)
    @amount = amount
    @currency = currency
    @source = source
    @description = description
  end

  def charge
    Stripe::Charge.create({
      amount: @amount,
      currency: @currency,
      source: @source,
      description: @description,
    })

    cased(:charge, payload: {
      amount: @amount,
      currency: @currency,
      description: @description,
    })
  end

  def cased_id
    'card_1dQpXqQwXxsQs9sohN9HrzRAV6y'
  end

  def cased_payload
    {
      credit_card: self,
    }
  end
end

credit_card = CreditCard.new(
  amount: 2000,
  currency: 'usd',
  source: 'tok_amex',
  description: 'My First Test Charge (created for API docs)',
)

credit_card.charge
```

Both examples above are equivelent in that they publish the following `credit_card.charge` event to Cased:

```json
{
  "cased_id": "5f8559cd-4cd9-48c3-b1d0-6eedc4019ec1",
  "action": "credit_card.charge",
  "amount": 2000,
  "currency": "usd",
  "source": "tok_amex",
  "description": "My First Test Charge (created for API docs)",
  "credit_card_id": "card_1dQpXqQwXxsQs9sohN9HrzRAV6y",
  "timestamp": "2020-06-23T02:02:39.932759Z"
}
```

#### Retrieving events from a Cased audit trail

If you plan on retrieving audit events from your Cased audit trail you must use a Cased API key.

```ruby
require 'cased-ruby'

Cased.configure do |config|
  config.policy_key = 'policy_live_1dQpY5JliYgHSkEntAbMVzuOROh'
end

query = Cased.policy.events.limit(25).page(1)
results = query.results
results.each do |event|
  puts event['action'] # => credit_card.charge
  puts event['timestamp'] # => 2020-06-23T02:02:39.932759Z
end
query.total_count # => 2,366
query.total_pages # => 95
query.success? # => true
query.error? # => false
```

#### Retrieving events from multiple Cased audit trails

To retrieve audit events from one or more Cased audit trails you can configure multiple Cased Policy API keys and retrieve events for each one.

```ruby
require 'cased-ruby'

Cased.configure do |config|
  config.policy_keys = {
    users: 'policy_live_1dQpY8bBgEwdpmdpVrrtDzMX4fH',
    organizations: 'policy_live_1dSHQRurWX8JMYMbkRdfzVoo62d',
  }
end

query = Cased.policies[:users].events.limit(25).page(1)
results = query.results
results.each do |event|
  puts event['action'] # => user.login
  puts event['timestamp'] # => 2020-06-23T02:02:39.932759Z
end

query = Cased.policies[:organizations].events.limit(25).page(1)
results = query.results
results.each do |event|
  puts event['action'] # => organization.create
  puts event['timestamp'] # => 2020-06-22T22:16:31.055655Z
end
```

#### Exporting events

Exporting events from Cased allows you to provide users with exports of their own data or to respond to data requests.

```ruby
require 'cased-ruby'

Cased.configure do |config|
  config.policy_key = 'policy_live_1dQpY5JliYgHSkEntAbMVzuOROh'
end

export = Cased.policy.exports.create(
  format: :json,
  phrase: 'action:credit_card.charge',
)
export.download_url # => https://api.cased.com/exports/export_1dSHQSNtAH90KA8zGTooMnmMdiD/download?token=eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoidXNlcl8xZFFwWThiQmdFd2RwbWRwVnJydER6TVg0ZkgiLCJ
```

#### Masking & filtering sensitive information

If you are handling sensitive information on behalf of your users you should consider masking or filtering any sensitive information.

```ruby
require 'cased-ruby'

Cased.configure do |config|
  config.publish_key = 'publish_live_1dQpY1jKB48kBd3418PjAotmEwA'
end

Cased.publish(
  action: 'credit_card.charge',
  user: Cased::Sensitive::String.new('john@organization.com', label: :email)
)
```

#### Console Usage

Most Cased events will be created by users from actions on the website from custom defined events or lifecycle callbacks. The exception is any console session where models may generate Cased events as you start to modify records.

By default any console session will include the hostname of where the console session takes place. Since every event must have an actor, you must set the actor at the beginning of your console session. If you don't know the user, it's recommended you create a system/robot user.

```ruby
# OTHER CONSOLE INITIALIZATION HERE
Cased.context.push(actor: @actor)
```

#### Disable publishing events

Although rare, there may be times where you wish to disable publishing events to Cased. To do so wrap your transaction inside of a `Cased.disable` block:

```ruby
Cased.disable do
  user.cased(:login)
end
```

Or you can configure the entire process to disable publishing events.

```
CASED_DISABLE_PUBLISHING=1 bundle exec ruby crawl.rb
```

#### Context

One of the most easiest ways to publish detailed events to Cased is to push contextual information on to the Cased context.

```ruby
require 'cased-ruby'

Cased.configure do |config|
  config.publish_key = 'publish_live_1dQpY1jKB48kBd3418PjAotmEwA'
end

Cased.context.merge(location: 'hostname.local')

Cased.publish(
  action: 'console.start',
  user: 'john',
)
```

Any information stored in `Cased.context` will be included anytime an event is published.

```json
{
  "cased_id": "5f8559cd-4cd9-48c3-b1d0-6eedc4019ec1",
  "action": "user.login",
  "user": "john",
  "location": "hostname.local",
  "timestamp": "2020-06-22T21:43:06.157336"
}
```

You can provide `Cased.context.merge` a block and the context will only be present for the duration of the block:

```ruby
Cased.context.merge(location: 'hostname.local') do
  # Will include { "location": "hostname.local" }
  Cased.publish(
    action: 'console.start',
    user: 'john',
  )
end

# Will not include { "location": "hostname.local" }
Cased.publish(
  action: 'console.end',
  user: 'john',
)
```

To clear/reset the context:

```ruby
Cased.context.clear
```

#### Testing

cased-ruby provides a test helper class that you can use to test events are being published to Cased.

```ruby
require 'test-helper'

class CreditCardTest < Test::Unit::TestCase
  include Cased::TestHelper

  def test_charging_credit_card_publishes_credit_card_create_event
    credit_card = CreditCard.new(
      amount: 2000,
      currency: 'usd',
      source: 'tok_amex',
      description: 'My First Test Charge (created for API docs)',
    )

    credit_card.charge

    assert_cased_events 1, action: 'credit_card.charge', amount: 2000
  end

  def test_charging_credit_card_publishes_credit_card_create_event_with_block
    credit_card = CreditCard.new(
      amount: 2000,
      currency: 'usd',
      source: 'tok_amex',
      description: 'My First Test Charge (created for API docs)',
    )

    assert_cased_events 1, action: 'credit_card.charge', amount: 2000 do
      credit_card.charge
    end
  end

  def test_charging_credit_card_with_zero_amount_does_not_publish_credit_card_create_event
    credit_card = CreditCard.new(
      amount: 0,
      currency: 'usd',
      source: 'tok_amex',
      description: 'My First Test Charge (created for API docs)',
    )

    assert_no_cased_events do
      credit_card.charge
    end
  end
end
```

### Customizing cased-ruby

Out of the box cased-ruby takes care of serializing objects for you to the best of its ability, but you can customize cased-ruby should you like to fit your products needs.

Let's look at each of these methods independently as they all work together to
create the event.

`Cased::Model#cased`

This method is what publishes events for you to Cased. You include information specific to a particular event when calling `Cased::Model#cased`:

```ruby
class CreditCard
  include Cased::Model

  # ...

  def charge
    Stripe::Charge.create({
      amount: @amount,
      currency: @currency,
      source: @source,
      description: @description,
    })

    cased(:charge, payload: {
      amount: @amount,
      currency: @currency,
      description: @description,
    })
  end
end
```

Or you can customize information that is included anytime `Cased::Model#cased` is called in your class:

```ruby
class CreditCard
  include Cased::Model

  # ...

  def charge
    Stripe::Charge.create({
      amount: @amount,
      currency: @currency,
      source: @source,
      description: @description,
    })

    cased(:charge)
  end

  def cased_payload
    {
      credit_card: self,
      amount: @amount,
      currency: @currency,
      description: @description,
    }
  end
end
```

Both examples are equivelent.

`Cased::Model#cased_category`

By default `cased_category` will use the underscore class name to generate the
prefix for all events generated by this class. If you published a
`CreditCard#charge` event it would be delivered to Cased `credit_card.charge`. If you want to
customize what cased-ruby uses you can do so by re-opening the method:

```ruby
class CreditCard
  include Cased::Model

  def cased_category
    :card
  end
end
```

`Cased::Model#cased_id`

Per our guide on [Human and machine readable information](https://docs.cased.com/guides/design-audit-trail-events#human-and-machine-readable-information) for [Designing audit trail events](https://docs.cased.com/guides/design-audit-trail-events) we encourage you to publish a unique identifier that will never change to Cased along with your events. This way when you [retrieve events](#retrieving-events-from-a-cased-policy) from Cased you'll be able to locate the corresponding object in your system.

```ruby
class User
  include Cased::Model

  def cased_id
    database_id
  end
end
```

`Cased::Model#cased_context`

To assist you in publishing events to Cased that are consistent and predictable, cased-ruby attempts to build your `cased_context` as long as you implement either `to_s` or `cased_id` in your class:

```ruby
class Plan
  include Cased::Model

  def initialize(name)
    @name = name
  end

  def cased_id
    database_id
  end

  def to_s
    @name
  end
end

plan = Plan.new('Free')
plan.to_s # => 'Free'
plan.cased_id # => 'plan_1dQpY1jKB48kBd3418PjAotmEwA'
plan.cased_context # => { plan: 'Free', plan_id: 'plan_1dQpY1jKB48kBd3418PjAotmEwA' }
```

If your class does not implement `to_s` it will only include `cased_id`:

```ruby
class Plan
  include Cased::Model

  def initialize(name)
    @name = name
  end

  def cased_id
    database_id
  end
end

plan = Plan.new('Free')
plan.to_s # => '#<Plan:0x00007feadf63b7e0>'
plan.cased_context # => { plan_id: 'plan_1dQpY1jKB48kBd3418PjAotmEwA' }
```

Or you can customize it if your `to_s` implementation is not suitable for Cased:

```ruby
class Plan
  include Cased::Model

  def initialize(name)
    @name = name
  end

  def cased_id
    'plan_1dQpY1jKB48kBd3418PjAotmEwA'
  end

  def to_s
    @name
  end

  def cased_context(category: cased_category)
    {
      "#{category}_id".to_sym => cased_id,
      category => @name.parameterize,
    }
  end
end

class CreditCard
  include Cased::Model

  def initialize(amount:, currency:, source:, description:)
    @amount = amount
    @currency = currency
    @source = source
    @description = description
  end

  def charge
    Stripe::Charge.create({
      amount: @amount,
      currency: @currency,
      source: @source,
      description: @description,
    })

    cased(:charge, payload: {
      amount: @amount,
      currency: @currency,
      description: @description,
    })
  end

  def plan
    Plan.new('Free')
  end

  def cased_id
    'card_1dQpXqQwXxsQs9sohN9HrzRAV6y'
  end

  def cased_payload
    {
      credit_card: self,
      plan: plan,
    }
  end
end

credit_card = CreditCard.new(
  amount: 2000,
  currency: 'usd',
  source: 'tok_amex',
  description: 'My First Test Charge (created for API docs)',
)

credit_card.charge
```

Results in:

```json
{
  "cased_id": "5f8559cd-4cd9-48c3-b1d0-6eedc4019ec1",
  "action": "credit_card.charge",
  "credit_card": "personal",
  "credit_card_id": "card_1dQpXqQwXxsQs9sohN9HrzRAV6y",
  "plan": "Free",
  "plan_id": "plan_1dQpY1jKB48kBd3418PjAotmEwA",
  "timestamp": "2020-06-22T20:24:04.815758"
}
```

## Contributing

1. Fork it ( https://github.com/cased/cased-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
