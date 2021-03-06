require 'nokogiri'
require 'open-uri'
require 'uri'
require_relative './user_agents.rb'

module XP
  def to_nokogiri
    source = url? ? self.page_source : self

    Nokogiri(source)
  end

  def page_source(user_agent_alias: :mac_firefox, user_agent: nil)
    user_agent ||= USER_AGENTS[user_agent_alias]
    open(self, "User-Agent" => user_agent).read
  end

  def download(location: 'downloads', name: nil)
    ::FileUtils.mkdir_p location

    filename = (name || basename).to_s + extension
    File.open("#{location}/#{filename}", 'wb') do |f|
      f.write open(self).read
    end
  end

  def css(selector)
    self.to_nokogiri.css(selector).to_html.to_nokogiri
  end

  def xpath(selector)
    self.to_nokogiri.xpath(selector).to_html.to_nokogiri
  end

  private

  def url?
    self.length < 200 && !(self =~ /\A#{URI::regexp}\z/).nil?
  end

  def basename
    self.match(regex)[:basename] if url?
  end

  def extension
    self.match(regex)[:extension] if url?
  end

  def regex
    /.*\/(?<basename>.*)(?<extension>\.\w+)(\?.*)?/
  end

end

String.send :include, XP
