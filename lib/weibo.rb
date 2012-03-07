# code is an adaptation of the twitter gem by John Nunemaker
# http://github.com/jnunemaker/twitter
# Copyright (c) 2009 John Nunemaker
#
# made to work with china's leading twitter service, 新浪微博

require 'forwardable'
require 'rubygems'
require 'oauth'
require 'hashie'
require 'httparty'


require 'weibo/oauth'
require 'weibo/oauth_hack'
require 'weibo/httpauth'
require 'weibo/request'
require 'weibo/config'
require 'weibo/base'


module Weibo
  class WeiboError < StandardError
    attr_reader :data

    def initialize(data)
      @data = data
      super
    end
  end
  class RepeatedWeiboText < WeiboError; end
  class RateLimitExceeded < WeiboError; end
  class Unauthorized      < WeiboError; end
  class General           < WeiboError; end

  class Unavailable       < StandardError; end
  class InformWeibo       < StandardError; end
  class NotFound          < StandardError; end
end

module Hashie
  class Mash
    # Converts all of the keys to strings, optionally formatting key name
    def rubyify_keys!
      keys.each{|k|
        v = delete(k)
        new_key = k.to_s.underscore
        self[new_key] = v
        v.rubyify_keys! if v.is_a?(Hash)
        v.each{|p| p.rubyify_keys! if p.is_a?(Hash)} if v.is_a?(Array)
      }
      self
    end
  end
end



if File.exists?('config/weibo.yml')
  weibo_oauth = YAML.load_file('config/weibo.yml')[Rails.env || env || 'development']
  Weibo::Config.api_key = weibo_oauth["api_key"]
  Weibo::Config.api_secret = weibo_oauth["api_secret"]
end

begin
if Rails
  require 'weibo/railtie'
end
rescue
end
