require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SojournerBo
  class Application < Rails::Application
    config.load_defaults 7.0

    config.firebase = config_for(:firebase)
    config.firebase.token = ENV['FIREBASE_ADMIN_TOKEN']
  end
end
