# encoding: UTF-8

module ProgressReporters
  autoload :ProgressReporter,          'progress-reporters/progress_reporter'
  autoload :NilProgressReporter,       'progress-reporters/nil_progress_reporter'
  autoload :StagedProgressReporter,    'progress-reporters/staged_progress_reporter'
  autoload :NilStagedProgressReporter, 'progress-reporters/nil_staged_progress_reporter'
  autoload :MeteredProgressReporter,   'progress-reporters/metered_progress_reporter'
end
