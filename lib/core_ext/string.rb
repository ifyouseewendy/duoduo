class String
  def parameterize(sep = '-')
    if self.ascii_only?
      ActiveSupport::Inflector.parameterize(self, sep)
    else
      Pinyin.t(self, splitter: '-')
    end
  end
end
