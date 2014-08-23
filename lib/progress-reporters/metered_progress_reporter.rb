# encoding: UTF-8

module ProgressReporters

  class MeteredProgressReporter < ProgressReporter
    CALC_TYPES = [:avg, :moving_avg]
    DEFAULT_MOVING_AVG_WINDOW_SIZE = 5
    DEFAULT_CALC_TYPE = :moving_avg
    DEFAULT_PRECISION = 2

    attr_reader :calc_type, :window_size, :precision

    def set_calc_type(calc_type)
      if CALC_TYPES.include?(calc_type)
        @calc_type = calc_type
        self
      else
        raise ArgumentError, "#{calc_type} is not a supported calculation type."
      end
    end

    def set_window_size(window_size)
      @window_size = window_size
      self
    end

    def set_precision(precision)
      @precision = precision
      self
    end

    def reset
      super
      @avg_sum = 0
      @avg_count = 0
      @avg_time_sum = 0
      @avg_window = []
      @avg_time_window = []
      @last_timestamp = nil
      @last_count = nil
    end

    def window_size
      (@window_size || DEFAULT_MOVING_AVG_WINDOW_SIZE).to_f
    end

    def calc_type
      @calc_type || DEFAULT_CALC_TYPE
    end

    def precision
      @precision || DEFAULT_PRECISION
    end

    protected

    # this won't get called if on_progress_proc is nil
    def notify_of_progress(count, total)
      on_progress_proc.call(
        count, total, percentage(count, total), rate(count, total)
      )
    end

    def rate(count, total)
      cur_time = Time.now

      rate = if @last_timestamp
        time_delta = cur_time - @last_timestamp
        count_delta = count - last_count
        apply_calc_type(time_delta, count_delta)
      else
        0
      end

      @last_timestamp = cur_time
      @last_count = count
      rate
    end

    def apply_calc_type(time_delta, count_delta)
      case calc_type
        when :avg
          apply_avg(time_delta, count_delta)
        when :moving_avg
          apply_moving_avg(time_delta, count_delta)
      end
    end

    def apply_avg(time_delta, count_delta)
      @avg_sum += count_delta
      @avg_time_sum += time_delta
      @avg_count += 1

      # (avg items) / (avg time) = avg items per second
      answer = (@avg_sum / @avg_count) / (@avg_time_sum / @avg_count)
      answer.round(precision)
    end

    def apply_moving_avg(time_delta, count_delta)
      add_window_element(time_delta, count_delta)
      avg_count = @avg_window.inject(&:+) / window_size
      avg_time = @avg_time_window.inject(&:+) / window_size
      (avg_count / avg_time).round(precision)
    end

    def add_window_element(time_delta, count_delta)
      if @avg_window.size >= window_size
        @avg_window.shift
        @avg_time_window.shift
      end

      @avg_window << count_delta
      @avg_time_window << time_delta
    end
  end

end
