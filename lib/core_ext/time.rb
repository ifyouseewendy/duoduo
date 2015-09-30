class Time
  class << self
    def stamp
      now.to_s(:db).gsub(/[\s:-]/, '')
    end
  end
end
