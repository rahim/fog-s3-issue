#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

config = {
  provider: 'AWS',
  region: 'us-west-2',
  aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
}

s3 = Fog::Storage.new(config)
bucket = s3.directories.new(key: 'litmus-dev-rahim-throwaway')
bucket.files.get('foo')
# =>   <Fog::AWS::Storage::File
#     key="foo",
#     cache_control=nil,
#     content_disposition=nil,
#     content_encoding=nil,
#     content_length=3,
#     content_md5=nil,
#     content_type="",
#     etag="37b51d194a7513e45b56f6524f2d51f2",
#     expires=nil,
#     last_modified=2023-09-19 15:18:30 +0000,
#     metadata={"x-amz-id-2"=>"P6b145GU6tllNufELCAYtGGNIvqijkuVoayaabSTGi3d4dVxzZCM5TYiaCgZhvOpmJO/SKTHyOnpQw65oXKXug==", "x-amz-request-id"=>"PAYX90KF2VFZMBVH"},
#     owner=nil,
#     storage_class=nil,
#     encryption="AES256",
#     encryption_key=nil,
#     version=nil,
#     kms_key_id=nil,
#     tags=nil,
#     website_redirect_location=nil
#   >
file = bucket.files.create(key: 'foo', body: 'bar')
bucket.files.get('foo')
file = bucket.files.create(key: 'foo', body: 'bar')
