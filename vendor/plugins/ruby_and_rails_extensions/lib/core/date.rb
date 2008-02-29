class Date
  include NiceStrftime

  def nice_strftime(directives = '%F')
    self.strftime(self.class.convert_nice_to_strftime_directives(directives))
  end
end
