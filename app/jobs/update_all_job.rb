class UpdateAllJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    UpdateService.new.update_all
  end
end
