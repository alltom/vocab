class DateTime
  include NiceStrftime

  def nice_strftime(directives = '%FT%T%:z')
    self.strftime(self.class.convert_nice_to_strftime_directives(directives))
  end
end
