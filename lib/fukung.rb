require 'net/http'
require 'cgi'
require 'uri'

module Fukung
  Host = 'fukung.net'
  MediaHost = 'media.fukung.net'
  Debug = ENV['FUKUNG_DEBUG']
  Nothing = Object.new.freeze

  def random
    @random ||= nil
    retries = 0

    begin
      location =
        request! do |http|
          headers = {}
          headers['Cookie'] = sfw_cookie if sfw?
          response = http.get('/random', headers)
          result! response['Location']
        end

      path = location.gsub(%r|^/v|, '')
      raise if path.strip.empty?
      raise if path.strip.downcase=='random'
      path = "http://" + "#{ MediaHost }/images/#{ path }".squeeze('/')
      raise if path=="http://#{ MediaHost }/images/random"
      @random = path
      return @random
    rescue
      if retries < 42
        retries += 1
        retry
      end
      raise unless @random
      @random
    end
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

    @sfw_cookie =
      request! do |http|
        response = http.get('/actions/toggleSFW.php')
        set_cookie = response['Set-Cookie']
        sfw_cookie = set_cookie.to_s.split(/;/).first + ';'
        result!(sfw_cookie)
      end
  end

  def tag(tag)
    page = 1
    max = 100
    imgs = []
    loop do
      body =
        request! do |http|
          path = "/tag/#{ CGI.escape(tag) }/page,#{ page }"
          response = http.get(path)
          result! response.body
        end
      uris = URI.extract(body, 'http').select{|uri| uri =~ /#{ MediaHost }/}
      break if uris.empty?
      uris.map!{|uri| uri.sub!('thumbs', 'images')}
      imgs.push(*uris)
      break if page > max
      page += 1
    end
    imgs.flatten.compact.uniq
  end

  def request!(&block)
    error = nil

    result =
      catch(:result) do
        4.times do |i|
          begin
            http = Net::HTTP::new(Host)
            http.set_debug_output(STDERR) if Debug
            http.start do
              block.call(http) if block
            end
          rescue Object => e
            error = e
            sleep rand
          end
        end
        Nothing
      end

    raise(error || 'unknown error') if result == Nothing
    return(result)
  end

  def result!(result)
    throw(:result, result)
  end

  extend(Fukung)

  Fukung.sfw!
end


if $0 == __FILE__
  puts Fukung.tag('lolcat')
  puts Fukung.sfw_cookie
  puts Fukung.random
end
