require_relative 'duoduo_cli'

class Business < DuoduoCli
  desc "test", ''
  def test
    load_rails
    init_logger

    logger.info "Test from Business thor"
  end
end

Business.start(ARGV)
