require 'logger'

# Examples
#
#   logger = DistinctFileLogger.new(STDOUT)
#   logger.set_error_path('/Users/wendi/tmp/logger/error.log')

#   logger.info "processing: 1/10"
#   logger.info "processing: 2/10"
#   logger.info "processing: 3/10"
#
#   # STDOUT
#   # I, [2015-12-10T22:30:06.749612 #63303]  INFO -- : processing: 1/10
#   # I, [2015-12-10T22:30:06.749672 #63303]  INFO -- : processing: 2/10
#   # I, [2015-12-10T22:30:06.749692 #63303]  INFO -- : processing: 3/10

#   logger.error "Validation failed on :email"
#   logger.error "Validation failed on :name"
#
#   # error.log
#   # # Logfile created on 2015-12-10 22:30:06 +0800 by logger.rb/47272
#   # E, [2015-12-10T22:30:06.749708 #63303] ERROR -- : Validation failed on :email
#   # E, [2015-12-10T22:30:06.749729 #63303] ERROR -- : Validation failed on :name

class DistinctFileLogger
  LOG_LEVEL = [:debug , :info , :warn , :error , :fatal , :unknown]

  def initialize(path)
    @loggers = {}
    LOG_LEVEL.each do |level|
      @loggers[level] = ActiveSupport::Logger.new(path)
    end
  end

  LOG_LEVEL.each do |level|
    define_method(level) do |message|
      @loggers[level].send(level, message)
    end

    define_method("set_#{level}_path") do |path|
      @loggers[level] = ActiveSupport::Logger.new(path)
    end
  end
end


