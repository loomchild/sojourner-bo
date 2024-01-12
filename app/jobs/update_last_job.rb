class UpdateLastJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    UpdateService.new.update_last
  end
end
