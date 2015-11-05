# Falcon

A simple wrapper to make it easier and less nerve-wracking to deploy to Heroku and roll code back when you mess things up. 

![falcon](http://static3.businessinsider.com/image/547378e869bedd312b36685a/landing.gif)

Inspired by Space X's awesome Falcon rocket, which is working towards the first combined take-off and safe landing, and drawn from [this gist](https://gist.github.com/guapolo/28729b95a7ef6b1aacf5).

Falcon aims to be a simple, pared-down, easy-to-use (and easy-to-maintain) solution to a very specific problem.

## Installation

> Note: This gem is built to use Heroku Toolbelt. It won't do anything if you don't have the Toolbelt installed. 

Add to your Gemfile (`:development` group is fine):

```ruby
gem 'falcon'
```

And then execute:

    $ bundle

## Usage

Falcon is run from the command line. It takes two arguments, `appname` and `command`, and an optional `--force` (or `-f`) flag.

The commands are: 

- `deploy` - Deploy code to your app.
- `migrations` - Deploy code to your app, turn on maintenance mode, run accompanying migrations, and turn maintenance off.
- `rollback` - Roll back the most recent deploy. This will *not* reverse migrations, so as the instructions stipulate, run `rake db:rollback` before this command as necessary.

The optional `-f` flag disables the above rollback warning. 

Some examples: 

```bash
falcon staging-appname deploy
# => Deploy code to your staging app

falcon my-prod-app migrations
# => Deploy code to production app, turn on maintenance mode, run accompanying migrations, and turn maintenance off


falcon app-name rollback -f
# => You will not be warned about migrations; falcon will go ahead and reverse the previous deploy

falcon help
# => ?
```

## Development

The usual:

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/sashafklein/falcon/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
