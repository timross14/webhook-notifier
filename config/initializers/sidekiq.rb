Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
  config.average_scheduled_poll_interval = 3
  schedule_file = "config/schedule.yml"
  if File.exists?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end
