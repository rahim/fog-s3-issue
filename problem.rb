#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

config = {
  provider: 'AWS',
  region: 'us-east-1',
  aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
}

s3 = Fog::Storage.new(config)
bucket = s3.directories.new(key: 'rahim-throwaway-us-east-1')
file = bucket.files.create(key: 'foo', body: 'bar')
file = bucket.files.get('foo')
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
i=0; loop { puts i+=1; file.save; sleep 0.5; }
# The file instance above carries state from previous API requests.
# In particular fog carries forward x-amz-id-2 and x-amz-request-id from
# the last response and includes that in the next request
#
# Most of the time S3 just ignores this silently, but intermittently it
# becomes more fussy and rejects with
#
# <?xml version=\\"1.0\\" encoding=\\"UTF-8\\"?>\\n<Error><Code>SignatureDoesNotMatch</Code><Message>The request signature we calculated does not match the signature you provided. Check your key and signing method.</Message><AWSAccessKeyId>AKIA4EAE47NL3ELESEWF</AWSAccessKeyId><StringToSign>AWS4-HMAC-SHA256\\n20230921T143905Z\\n20230921/us-east-1/s3/aws4_request\\n026e7b083a96ce9f3a3b6eca74eac7f0393b900880e428d48b63d4d6837ac81b</StringToSign><SignatureProvided>6c4dd60c35470f0a74feccb5a0f3efd78bdbae9d0ce8bcd3fbb3f501ac3f14dc</SignatureProvided><StringToSignBytes>41 57 53 34 2d 48 4d 41 43 2d 53 48 41 32 35 36 0a 32 30 32 33 30 39 32 31 54 31 34 33 39 30 35 5a 0a 32 30 32 33 30 39 32 31 2f 75 73 2d 65 61 73 74 2d 31 2f 73 33 2f 61 77 73 34 5f 72 65 71 75 65 73 74 0a 30 32 36 65 37 62 30 38 33 61 39 36 63 65 39 66 33 61 33 62 36 65 63 61 37 34 65 61 63 37 66 30 33 39 33 62 39 30 30 38 38 30 65 34 32 38 64 34 38 62 36 33 64 34 64 36 38 33 37 61 63 38 31 62</StringToSignBytes><CanonicalRequest>PUT\\n/foo\\n\\ncontent-length:3\\ncontent-type:\\nhost:rahim-throwaway-us-east-1.s3.amazonaws.com\\nx-amz-content-sha256:fcde2b2edba56bf408601fb721fe9b5c338d10ee429ea04fae5511b68fbf8fb9\\nx-amz-date:20230921T143905Z\\nx-amz-id-2:\\nx-amz-request-id:\\nx-amz-server-side-encryption:AES256\\n\\ncontent-length;content-type;host;x-amz-content-sha256;x-amz-date;x-amz-id-2;x-amz-request-id;x-amz-server-side-encryption\\nfcde2b2edba56bf408601fb721fe9b5c338d10ee429ea04fae5511b68fbf8fb9</CanonicalRequest><CanonicalRequestBytes>50 55 54 0a 2f 66 6f 6f 0a 0a 63 6f 6e 74 65 6e 74 2d 6c 65 6e 67 74 68 3a 33 0a 63 6f 6e 74 65 6e 74 2d 74 79 70 65 3a 0a 68 6f 73 74 3a 72 61 68 69 6d 2d 74 68 72 6f 77 61 77 61 79 2d 75 73 2d 65 61 73 74 2d 31 2e 73 33 2e 61 6d 61 7a 6f 6e 61 77 73 2e 63 6f 6d 0a 78 2d 61 6d 7a 2d 63 6f 6e 74 65 6e 74 2d 73 68 61 32 35 36 3a 66 63 64 65 32 62 32 65 64 62 61 35 36 62 66 34 30 38 36 30 31 66 62 37 32 31 66 65 39 62 35 63 33 33 38 64 31 30 65 65 34 32 39 65 61 30 34 66 61 65 35 35 31 31 62 36 38 66 62 66 38 66 62 39 0a 78 2d 61 6d 7a 2d 64 61 74 65 3a 32 30 32 33 30 39 32 31 54 31 34 33 39 30 35 5a 0a 78 2d 61 6d 7a 2d 69 64 2d 32 3a 0a 78 2d 61 6d 7a 2d 72 65 71 75 65 73 74 2d 69 64 3a 0a 78 2d 61 6d 7a 2d 73 65 72 76 65 72 2d 73 69 64 65 2d 65 6e 63 72 79 70 74 69 6f 6e 3a 41 45 53 32 35 36 0a 0a 63 6f 6e 74 65 6e 74 2d 6c 65 6e 67 74 68 3b 63 6f 6e 74 65 6e 74 2d 74 79 70 65 3b 68 6f 73 74 3b 78 2d 61 6d 7a 2d 63 6f 6e 74 65 6e 74 2d 73 68 61 32 35 36 3b 78 2d 61 6d 7a 2d 64 61 74 65 3b 78 2d 61 6d 7a 2d 69 64 2d 32 3b 78 2d 61 6d 7a 2d 72 65 71 75 65 73 74 2d 69 64 3b 78 2d 61 6d 7a 2d 73 65 72 76 65 72 2d 73 69 64 65 2d 65 6e 63 72 79 70 74 69 6f 6e 0a 66 63 64 65 32 62 32 65 64 62 61 35 36 62 66 34 30 38 36 30 31 66 62 37 32 31 66 65 39 62 35 63 33 33 38 64 31 30 65 65 34 32 39 65 61 30 34 66 61 65 35 35 31 31 62 36 38 66 62 66 38 66 62 39</CanonicalRequestBytes><RequestId>EBRC49GT99QS4Q0R</RequestId><HostId>wMk9wMGpEYnTmYTpCqeA7Irs0766XS1A1FCNDn63w4AdqTNqDazeYT/JIy4VZJc8nHhnCPq2mTE=</HostId></Error>
