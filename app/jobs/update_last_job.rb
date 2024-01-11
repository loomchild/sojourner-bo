class UpdateLastJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    UpdateService.new.reset_last
  end
end
