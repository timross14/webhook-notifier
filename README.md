# Notifier

###Known Issues/Possible Improvements
- Need better handling of errors and testing of API returns
- Should research if there is a worker gem that is more built for our use case, Sidekiq needs manipulating to queue quickly
- Possibly parallelize our GET of weather status, as we scale up the amount of zip codes
- Need to manually test if sidekiq jobs are working

###To Run Tests
`bundle install && bundle exec rspec`

_Notifier_ app monitors the weather in your area and will notify you when
a weather alert is declared. The notification happens in the form a webhook to
provide flexibility and timeliness.

## Architecture

A `Webhook` is composed of the following attributes:

- `name`
  - `name` will be restricted to one of "watch" or "warning"
- `url`
  - `url` will be the Web address to send an HTTP GET request to
- `zip_code`
  - `zip_code` is the region within the US that a user would like to monitor for weather changes

Each attempt (i.e. HTTP request) to perform a webhook will result in
a `WebhookEvent` database record. The `WebhookEvent` model will be composed of
the following attributes:

- `webhook_id`
  - `webhook_id` will associate a `WebhookEvent` to a `Webhook`
- `status`
  - `status` will store the HTTP response code received from executing the `Webhook`
- `response`
  - `response` will store the HTTP response body received from executing the `Webhook`

`WeatherCheckService` is responsible for retrieving weather updates and
generating webhook events.

