# encoding: UTF-8

require 'spec_helper'

include ProgressReporters

describe ProgressReporters::ProgressReporter do
  before(:each) do
    collector  # call to instantiate collector
  end

  context 'with a linear reporter' do
    let(:reporter) { ProgressReporter.new }
    let(:collector) { LinearCollector.new(reporter) }

    context 'with a linear task' do
      let(:task) { LinearTask.new(reporter) }

      it 'reports progress' do
        task.execute(10)

        collector.progress_notifications.each_with_index do |notification, idx|
          expect(notification.quantity).to eq(idx)
          expect(notification.total).to eq(10)
          expect(notification.percentage).to eq(10 * idx)
        end

        expect(collector.complete_notification).to_not be_nil
      end

      it 'should only report progress every other time when step is set to 2' do
        reporter.set_step(2)
        task.execute(10)

        expect(collector.progress_notifications.size).to eq(5)

        collector.progress_notifications.each_with_index do |notification, idx|
          expect(notification.quantity).to eq(idx * 2)
          expect(notification.total).to eq(10)
          expect(notification.percentage).to eq(10 * (idx * 2))
        end
      end

      it 'should be able to reset itself' do
        task.execute(10)
        expect(reporter.last_count).to eq(9)
        reporter.reset
        expect(reporter.last_count).to eq(0)
      end
    end

    context 'with a nil reporter' do
      let(:reporter) { NilProgressReporter.new }
      let(:collector) { LinearCollector.new(reporter) }

      context 'with a linear task' do
        let(:task) { LinearTask.new(reporter) }

        it 'should not actually report any progress' do
          task.execute(10)
          expect(collector.progress_notifications).to be_empty
          expect(collector.complete_notification).to be_nil
        end
      end
    end
  end
end
