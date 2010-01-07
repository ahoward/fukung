require 'net/http'

module Fukung
  Host = 'fukung.net'
  MediaHost = 'media.fukung.net'

  class << Fukung
    def random
      begin
        location = Net::HTTP::start('fukung.net'){|http| http.get('/random')}['Location']
        path = location.gsub(%r|^/v|, '')
        path = "http://" + "#{ MediaHost }/images/#{ path }".squeeze('/')
        @random = path
      rescue Object => e
        raise e unless defined?(@random)
        @random
      end
    end
  end
end


if $0 == __FILE__
  puts Fukung.random
end
