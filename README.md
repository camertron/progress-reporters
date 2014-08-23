progress-reporters
==================

Callback-oriented way to report the progress of a task.

## Installation

`gem install progress-reporters`

## Usage

```ruby
require 'progress-reporters'
```

### Reporting Progress

Progress reporters follow the producer/consumer pattern. You'll create a progress reporter (the consumer) and pass it to the task that needs to report progress (the producer).

Let's say you'd like to report the progress of processing a batch of images. You've defined this image processor class to do the work:

```ruby
class ImageProcessor
  attr_accessor :image_files

  def initialize(image_files)
    @image_files = Array(image_files)
  end

  def process!
    @image_files.each do |image_file|
      process_image_file(image_file)
    end
  end

  private

  def process_image_file(image_file)
    # do some work
  end
end
```

To track the progress of your job, introduce a good ol' progress reporter:

```ruby
class ImageProcessor
  ...

  def process!(progress_reporter)
    @image_files.each_with_index do |image_file, idx|
      process_image_file(image_file)
      progress_reporter.report_progress(idx, @image_files.size)
    end

    progress_reporter.report_complete
  end

  ...
end

reporter = ProgressReporters::ProgressReporter.new
  .on_progress do |quantity, total, percentage|
    puts "#{quantity} of #{total} processed (#{percentage}%)"
  end
  .on_complete do
    puts 'done!'
  end

processor = ImageProcessor.new(['file1.png', 'file2.jpg'])
processor.process!(reporter)
```

I know what you're thinking. "This guy just slapped a sticker on a few Ruby blocks and called them a progress reporter." But it gets better.

### Reporting Progress in Stages

Progress reporting can get much more exciting. Let's start by considering a progress reporter that can handle a task that happens in stages:

```ruby
class ImageProcessor
  ...

  def process!(progress_reporter)
    auto_rotate!(progress_reporter)
    auto_crop!(progress_reporter)
    progress_reporter.report_complete
  end

  private

  def auto_rotate!(progress_reporter)
    progress_reporter.change_stage(:rotate)

    @image_files.each_with_index do |image_file, idx|
      auto_rotate_image(image_file)
      progress_reporter.report_progress(idx, @image_files.size)
    end

    progress_reporter.report_stage_finished(@image_files.size, @image_files.size)
  end

  def auto_crop!(progress_reporter)
    progress_reporter.change_stage(:crop)

    @image_files.each_with_index do |image_file, idx|
      auto_crop_image(image_file)
      progress_reporter.report_progress(idx, @image_files.size)
    end

    progress_reporter.report_stage_finished(@image_files.size, @image_files.size)
  end
end
```

### Reporting Metered Progress

## Authors

* Cameron C. Dutro: http://github.com/camertron

## Running Tests

`bundle exec rake` should do the trick :)
