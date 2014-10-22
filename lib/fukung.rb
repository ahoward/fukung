require 'net/http'
require 'cgi'
require 'uri'
require 'launchy'

module Fukung
  def Fukung.version
    '2.0.0'
  end

  Host = 'fukung.net'
  MediaHost = 'media.fukung.net'
  Debug = ENV['FUKUNG_DEBUG']
  Nothing = Object.new.freeze
  ENV['LAUNCHY_DEBUG'] = "true" if Debug

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

      basename = File.basename(location)

      #path = location.gsub(%r|^/v|, '')
      #raise if path.strip.empty?
      #raise if path.strip.downcase=='random'
      path = "http://" + "#{ MediaHost }/imgs/#{ basename }".squeeze('/')
      raise if path=="http://#{ MediaHost }/imgs/random"
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

  def random_or_tag(a_tag = false)
    list = a_tag ? Fukung.tag(a_tag.to_s) : [Fukung.random]
    raise "nothing found" if list.empty?
    return list
  end

  def one(a_tag = false)
    random_or_tag(a_tag).sort_by{ rand }.first
  end

  def goto(a_tag = false)
    random_or_tag(a_tag).each { |url| ::Launchy.open( url ) }
  end

  def goto_one(a_tag = false)
    ::Launchy.open(one(a_tag))
  end

  extend(Fukung)

  Fukung.sfw!
end


if $0 == __FILE__
  puts Fukung.tag('lolcat')
  puts Fukung.sfw_cookie
  puts Fukung.random
end
