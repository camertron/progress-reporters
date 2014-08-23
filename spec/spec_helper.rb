# encoding: UTF-8

require 'rspec'
require 'progress-reporters'
require 'timecop'
require 'pry-nav'

RSpec.configure do |config|
  config.mock_with :rr
end

LinearNotification = Struct.new(:quantity, :total, :percentage)
StagedNotification = Struct.new(:quantity, :total, :percentage, :stage)
StageChangedNotification = Struct.new(:new_stage, :old_stage)
MeteredNotification = Struct.new(:quantity, :total, :percentage, :rate)

class LinearCollector
  attr_reader :progress_reporter
  attr_reader :progress_notifications, :complete_notification

  def initialize(progress_reporter)
    @progress_notifications = []

    @progress_reporter = progress_reporter
      .on_progress { |*args| on_progress(*args) }
      .on_complete { |*args| on_complete(*args) }

    after_initialize
  end

  protected

  def after_initialize
  end

  def on_progress(*args)
    @progress_notifications << make_notification(*args)
  end

  def on_complete(*args)
    if @complete_notification
      raise StandardError, 'task already complete'
    else
      @complete_notification = make_notification(*args)
    end
  end

  def make_notification(*args)
    LinearNotification.new(*args)
  end
end

class StagedCollector < LinearCollector
  attr_reader :stage_changed_notifications

  protected

  def after_initialize
    @stage_changed_notifications = []
    progress_reporter.on_stage_changed { |*args| on_stage_changed(*args) }
  end

  def on_stage_changed(*args)
    @stage_changed_notifications << StageChangedNotification.new(*args)
  end

  def make_notification(*args)
    StagedNotification.new(*args)
  end
end

class MeteredCollector < LinearCollector
  def make_notification(*args)
    MeteredNotification.new(*args)
  end
end

class Task
  attr_reader :progress_reporter

  def initialize(progress_reporter)
    @progress_reporter = progress_reporter
  end
end

class LinearTask < Task
  def execute(quantity = 10)
    quantity.times do |i|
      progress_reporter.report_progress(i, quantity)
    end

    progress_reporter.report_complete
  end
end

class StagedTask < Task
  def execute(stages = 2, quantity_per_stage = 10)
    progress_reporter.set_stage(:stage_1)

    stages.times do |stage|
      quantity_per_stage.times do |i|
        progress_reporter.report_progress(i, quantity_per_stage)
      end

      progress_reporter.report_stage_finished(
        quantity_per_stage, quantity_per_stage
      )

      progress_reporter.change_stage(:"stage_#{stage + 2}")
    end

    progress_reporter.report_complete
  end
end

class MeteredTask < Task
  def execute(quantity = 10, delay_seconds = 1, rate_of_delay = 1)
    Timecop.freeze do
      quantity.times do |i|
        progress_reporter.report_progress(i, quantity)
        Timecop.travel(Time.now + delay_seconds + (rate_of_delay * i))
      end

      progress_reporter.report_complete
    end
  end
end
