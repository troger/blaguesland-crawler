#!/usr/bin/env ruby

require "net/http"
require "uri"
require 'nokogiri'
require 'open-uri'
require 'optparse'

URLS = [
  'http://blaguesland.free.fr/Classiques.htm',
  'http://blaguesland.free.fr/Blondes.htm',
  'http://blaguesland.free.fr/Blondes02.htm',
  'http://blaguesland.free.fr/Femmes.htm',
  'http://blaguesland.free.fr/Hommes.htm'
]

CONTRIBUTORS = [
  'Fred', 'Paolo', 'Sebastien', 'Alain', 'Arnaud', 'Cyril', 'Lise', 'Thomas', 
  'Julien', 'Leo', 'Lucette', 'Ginette', 'Julia', 'Paul', 'Mathieu', 'Megan',
  'Lea', 'Eric', 'Benjamin', 'Chloe', 'Olivier', 'Laurent', 'Laurence'
]

class JokeParser
  attr_accessor :url, :max_characters
  
  def initialize(url, max_characters)
    @url = url
    @max_characters = max_characters
  end
  
  def parse
    jokes = []
    doc = Nokogiri::HTML(open(@url))
    doc.css('h5').each do |joke|
      text = ""
      joke.content.each_line do |s|
        s = s.gsub(/ ?\(Q\)/, "")  
        s = s.gsub(/\s\(R\) /, "")
        s = s.gsub(/^ +/, "")
        s = s.gsub(/ \n/, "\n")
        text += s unless s.match("^\s*$")
      end
      text.strip!
      jokes << text unless text.length > @max_characters || text.length < 10
    end
    jokes
  end

  def to_s
    "URL: #@url, max characters: #@max_characters"
  end
end

class SosMessageClient
  attr_accessor :sosmessage_url, :category_id, :post_url

  def initialize(sosmessage_url, category_id)
    @sosmessage_url = sosmessage_url
    @category_id = category_id
    @post_url = @sosmessage_url << "/api/v1/categories/" << @category_id << "/message"
  end

  def postJokes(jokes)
    uri = URI.parse(@post_url)
    jokes_posted = 0
    jokes.each do |joke|
      response = Net::HTTP.post_form(uri, {"text" => joke, "contributorName" => CONTRIBUTORS.sample})
      jokes_posted += 1 if response.code.to_i == 204
    end
    puts jokes_posted.to_s << " jokes succesfully posted."
  end

  def to_s
    "SosMessag API URL: #@post_url"
  end
end

options = {}
 
optparse = OptionParser.new do|opts|
  opts.banner = 'Usage: blaguesland-crawler.rb [options]'

  options[:categoryid] = nil
  opts.on('-c', '--category-id CATEGORY_ID', 'The category id where to post the jokes') do |category|
    options[:categoryid] = category
  end

  options[:sosmessageurl] = 'http://localhost:3000'
  opts.on('-url', '--sosmessage-url URL', 'The SosMessage API url') do |url|
    options[:sosmessageurl] = url
  end
 
  options[:maxcharacters] = 150
  opts.on( '-m', '--max-characters MAX', Integer, 'MAX characters of the joke') do |max_characters|
    options[:maxcharacters] = max_characters
  end

  options[:dryrun] = false
  opts.on( '-n', '--dry-run', "Don't actually post the jokes, only display them") do |dry_run|
    options[:dryrun] = dry_run
  end
 
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

if options[:dryrun]
  URLS.each do |url|
    jokes = JokeParser.new(url, options[:maxcharacters]).parse
    jokes.each do |joke|
      puts joke
      puts ""
      puts "=========="
      puts ""
    end
  end
elsif options[:categoryid]
  client = SosMessageClient.new(options[:sosmessageurl], options[:categoryid])
  URLS.each do |url|
    jokes = JokeParser.new(url, options[:maxcharacters]).parse
    client.postJokes(jokes)
  end
end
