if Rails.env.production?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*'
      resource '/public/conferences/*', headers: :any, methods: [:get]
    end
  end
end
