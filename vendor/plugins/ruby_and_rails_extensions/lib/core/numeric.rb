# From http://blog.zenspider.com/archives/2007/04/i_doubt_ill_have_another_release_of_zenhacks_so_stiw4.html
class Numeric
  def commify(dec='.', sep=',')
    num = to_s.sub(/\./, dec)
    dec = Regexp.escape dec
    num.reverse.gsub(/(\d\d\d)(?=\d)(?!\d*#{dec})/, "\\1#{sep}").reverse
  end
end