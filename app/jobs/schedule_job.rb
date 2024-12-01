class ScheduleJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    ScheduleService.new.fetch_schedule
  end
end

