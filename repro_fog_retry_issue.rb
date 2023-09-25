#!/usr/bin/env ruby

# This demonstrates a tangentially related issue in fog-aws/excon, where
# attempting a GET of an S3 object that may or may not exist takes 6s due
# to the default retry behaviour.

require 'bundler/setup'
Bundler.require(:default)

require 'benchmark'

config = {
  provider: 'AWS',
  region: 'us-east-1',
  aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
}

s3 = Fog::Storage.new(config)
bucket = s3.directories.new(key: 'rahim-throwaway-us-east-1')

bm_default = Benchmark.measure { file = bucket.files.get('definitely-does-not-exist') }

puts
puts "Fog/Excon defaults (retry_limit: 5, retry_interval: 1)"
puts
puts bm_default
puts

s3 = Fog::Storage.new(config.merge(
  connection_options: { retry_limit: 5, retry_interval: 0.1 }
))
bucket = s3.directories.new(key: 'rahim-throwaway-us-east-1')

bm_less_interval = Benchmark.measure { file = bucket.files.get('definitely-does-not-exist') }

puts
puts "Using retry_limit: 5, retry_interval: 0.1"
puts
puts bm_less_interval
puts

s3 = Fog::Storage.new(config.merge(
  connection_options: { retry_limit: 1, retry_interval: 1 }
))
bucket = s3.directories.new(key: 'rahim-throwaway-us-east-1')

bm_less_retries = Benchmark.measure { file = bucket.files.get('definitely-does-not-exist') }

puts
puts "Using retry_limit: 1, retry_interval: 1"
puts
puts bm_less_retries
puts

s3 = Fog::Storage.new(config.merge(
  connection_options: { retry_errors: [Excon::Error::Timeout, Excon::Error::Socket, Excon::Error::Server] }
))
bucket = s3.directories.new(key: 'rahim-throwaway-us-east-1')

bm_less_errors = Benchmark.measure { file = bucket.files.get('definitely-does-not-exist') }

puts
puts "Using retry_errors: [Excon::Error::Timeout,Excon::Error::Socket,Excon::Error::Server]"
puts
puts bm_less_errors
puts
