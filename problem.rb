#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'fog-aws', '= 3.19.0'
end

config = {
  provider: 'AWS',
  region: 'us-west-2',
  aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
}

s3 = Fog::Storage.new(config)
directory = s3.directories.new(key: 'litmus-dev-rahim-throwaway')
directory.files.get('foo')
file = directory.files.create(key: 'foo', body: 'bar')
