# encoding: UTF-8

require 'spec_helper'

include ProgressReporters

describe ProgressReporters::StagedProgressReporter do
  before(:each) do
    collector  # call to instantiate collector
  end

  context 'with a staged reporter' do
    let(:reporter) { StagedProgressReporter.new }
    let(:collector) { StagedCollector.new(reporter) }

    context 'with a staged task' do
      let(:task) { StagedTask.new(reporter) }

      it 'reports progress in stages' do
        task.execute(2, 10)

        expect(collector.progress_notifications.size).to eq(20)

        collector.progress_notifications.each_with_index do |notification, idx|
          expect(notification.quantity).to eq(idx % 10)
          expect(notification.total).to eq(10)
          expect(notification.percentage).to eq((idx % 10) * 10)
          expect(notification.stage).to eq(:"stage_#{(idx / 10) + 1}")
        end

        expect(collector.stage_changed_notifications.size).to eq(2)

        collector.stage_changed_notifications.tap do |notifications|
          notifications[0].first do |notification|
            expect(notification.old_stage).to_eq(:stage_1)
            expect(notification.new_stage).to eq(:stage_2)
          end

          notifications[1].first do |notification|
            expect(notification.old_stage).to_eq(:stage_2)
            expect(notification.new_stage).to eq(:stage_3)
          end
        end
      end
    end

    context 'with a nil reporter' do
      let(:reporter) { NilStagedProgressReporter.new }
      let(:collector) { StagedCollector.new(reporter) }

      context 'with a linear task' do
        let(:task) { StagedTask.new(reporter) }

        it 'should not actually report any progress' do
          task.execute(10)
          expect(collector.progress_notifications).to be_empty
          expect(collector.stage_changed_notifications).to be_empty
          expect(collector.complete_notification).to be_nil
        end
      end
    end
  end
end
