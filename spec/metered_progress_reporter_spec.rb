# encoding: UTF-8

require 'spec_helper'

include ProgressReporters

describe ProgressReporters::MeteredProgressReporter do
  before(:each) do
    collector  # call to instantiate collector
  end

  context 'with a metered reporter' do
    let(:reporter) { MeteredProgressReporter.new }
    let(:collector) { MeteredCollector.new(reporter) }

    context 'with a staged task' do
      let(:task) { MeteredTask.new(reporter) }

      it 'reports progress and calculates the average rate' do
        reporter.set_calc_type(:avg)
        task.execute(10, 0.5, 0)

        collector.progress_notifications.each_with_index do |notification, idx|
          expect(notification.quantity).to eq(idx)
          expect(notification.total).to eq(10)
          expect(notification.percentage).to eq(idx * 10)
          expect(notification.rate).to eq(idx == 0 ? 0 : 2.0)
        end
      end

      it 'reports progress and calculates the moving average rate' do
        reporter.set_calc_type(:moving_avg)
        reporter.set_window_size(2)
        task.execute(10, 1, 1)

        collector.progress_notifications.each_with_index do |notification, idx|
          expect(notification.quantity).to eq(idx)
          expect(notification.total).to eq(10)
          expect(notification.percentage).to eq(idx * 10)

          rate = case idx
            when 0 then 0.0
            when 1 then 1.0
            else
              (1 / (0.5 + (idx - 1))).round(2)
          end

          expect(notification.rate).to eq(rate)
        end
      end
    end
  end
end
