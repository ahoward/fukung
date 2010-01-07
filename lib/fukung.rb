require 'net/http'

module Fukung
  Host = 'fukung.net'
  MediaHost = 'media.fukung.net'
  Debug = ENV['FUKUNG_DEBUG']

  def random
    @random ||= nil
    error = nil

    4.times do |i|
      begin
        location = ''
        http = Net::HTTP::new('fukung.net')
        http.set_debug_output(STDERR) if Debug
        http.start do
          headers = {}
          headers['Cookie'] = sfw_cookie if sfw?
          p headers
          response = http.get('/random', headers)
          location = response['Location']
        end
        path = location.gsub(%r|^/v|, '')
        raise if path.strip.empty?
        raise if path.strip.downcase=='random'
        path = "http://" + "#{ MediaHost }/images/#{ path }".squeeze('/')
        raise if path=="http://#{ MediaHost }/images/random"
        @random = path
        return @random
      rescue Object => e
        error = e
        sleep rand
      end
    end

    raise(error || 'unknown error')
  end

  def sfw!
    @nsfw = false
  end
  def sfw?
    @nsfw ||= nil 
    !!!@nsfw
  end

  def nsfw!
    @nsfw = true
  end
  def nsfw?
    @nsfw ||= nil
    !!@nsfw
  end

  def sfw_cookie
    return @sfw_cookie if defined?(@sfw_cookie)
    error = nil

    4.times do |i|
      begin
        http = Net::HTTP::new('fukung.net')
        http.set_debug_output(STDERR) if Debug
        http.start do
          response = http.get('/actions/toggleSFW.php')
          set_cookie = response['Set-Cookie']
          @sfw_cookie = set_cookie.to_s.split(/;/).first + ';'
          return @sfw_cookie
        end
      rescue Object => e
        error = e
        sleep rand
      end
    end

    raise(error || 'unknown error')
  end

  extend(Fukung)

  Fukung.sfw!
end


if $0 == __FILE__
  puts Fukung.random
  # puts Fukung.sfw_cookie
end
