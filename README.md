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
  def initialize(image_files)
    @image_files = Array(image_files)
  end

  def process!
    @image_files.each do |image_file|
    end
  end
  
end
```

