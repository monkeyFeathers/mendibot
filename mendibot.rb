require 'rubygems'
require 'isaac'
require "#{File.dirname(__FILE__)}/bot_config"
require 'rest_client'
require 'json'
require 'date'
require 'cgi'
require 'yelpbot'

$topics = {}

on :channel, /^!site$/ do
  msg channel, "http://university.rubymendicant.com"
end

on :channel, /^!topic (.*)/ do
  $topics[channel] = match[0]
  msg channel, "The topic is now #{$topics[channel]}"
end

on :channel, /^!topic$/ do
  topic = $topics[channel]
  if topic
    msg channel, "The topic is currently #{$topics[channel]}"
  else
    msg channel, "The topic is not currently set"
  end
end

on :channel do
  msg = { 
    :channel     => channel, 
    :handle      => nick, 
    :body        => message, 
    :recorded_at => DateTime.now,
    :topic       => $topics[channel]
  }.to_json
  
  service["/chat/messages.json"].post(:message => msg)
end

#############################################################################
# YelpBot
############################################################################

on :channel, /^!yelp (.*)/ do
  if match[0] == "-h" or match[0] == "help"
    msg channel, YelpBot::YelpHelp
  # elsif match[0].match /^(crack )/i
  #   msg channel, YelpBot::YelpCrackClarify
  # elsif match[0].match /^crack+cocaine/i
  #   msg channel, "hello world"
  else
    @yelp_query = YelpBot::Query.new match[0]
    @yelp_results = @yelp_query.get
    msg channel, "#{nick}: #{@yelp_results.to_irc}"
  end
end
