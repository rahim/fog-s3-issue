# Fog S3 header issue minimal reproduction

## To reproduce fog issue

This demonstrates fog reflecting request id headers provided in one API response in a subsequent request.

```
bundle
```

Run with

```
$ export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXX
$ export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXX
$ EXCON_DEBUG=1 ./repro_fog_issue.rb 2>&1 | grep "amz-id\|GET\|PUT\|excon.request\|excon.response"

excon.request
  :method              => "PUT"
excon.response
    "x-amz-id-2"                   => "3mWM5oTOUAbEAiqNjL2HVs78rN3GE1iv+JlhAx29SCshjYtcOY++YE4hNmAw0DssaUhXoUIdQz3S6iw6HT0ipw66uuKbgLin"
  :method            => "PUT"
excon.request
  :method              => "GET"
excon.response
    "x-amz-id-2"                   => "rRHar4PgxIl8tH6z/jq+i//GSgZ0rehaFSDWwG4AYqWxeicfMeGjqVHHcSYchUH1/rU0ihA5q3jritrzfTAzTVUQt4EdPcLw"
  :method            => "GET"
excon.request
    "x-amz-id-2"                   => "rRHar4PgxIl8tH6z/jq+i//GSgZ0rehaFSDWwG4AYqWxeicfMeGjqVHHcSYchUH1/rU0ihA5q3jritrzfTAzTVUQt4EdPcLw" ⚠️ !!! Our problem header !!!
  :method              => "PUT"
excon.response
    "x-amz-id-2"                   => "iEw4Ms6tofrnpetX5hgKtvAvLBA3NkDSReaZHrQrxUwUI8hNoMBxKxA1kTi4f0EnHv2TKI1gIcc="
  :method            => "PUT"
```

## Reproduce S3 issue

This demonstrates S3's new behaviour of sporadically rejecting requests that provide unwanted `x-amz-id-2` or `x-amz-request_id` headers.

```
bundle
```

```
$ export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXX
$ export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXX
$ ./repro_s3_issue.rb
1
2
3
4
5

... loops until the intermittent rejection occurs

931
932
Traceback (most recent call last):
	12: from ./repro_s3_issue.rb:38:in `<main>'
	11: from ./repro_s3_issue.rb:38:in `loop'
	10: from ./repro_s3_issue.rb:38:in `block in <main>'
	 9: from /Users/rahim/.rbenv-arm/versions/2.7.2/lib/ruby/gems/2.7.0/gems/fog-aws-1.4.0/lib/fog/aws/models/storage/file.rb:219:in `save'
	 8: from /Users/rahim/.rbenv-arm/versions/2.7.2/lib/ruby/gems/2.7.0/gems/fog-aws-1.4.0/lib/fog/aws/requests/storage/put_object.rb:47:in `put_object'
	 7: from /Users/rahim/.rbenv-arm/versions/2.7.2/lib/ruby/gems/2.7.0/gems/fog-aws-1.4.0/lib/fog/aws/storage.rb:607:in `request'
	 6: from /Users/rahim/.rbenv-arm/versions/2.7.2/lib/ruby/gems/2.7.0/gems/fog-aws-1.4.0/lib/fog/aws/storage.rb:612:in `_request'
	 5: from /Users/rahim/.rbenv-arm/versions/2.7.2/lib/ruby/gems/2.7.0/gems/fog-xml-0.1.3/lib/fog/xml/connection.rb:9:in `request'
	 4: from /Users/rahim/.rbenv-arm/versions/2.7.2/lib/ruby/gems/2.7.0/gems/fog-core-1.45.0/lib/fog/core/connection.rb:81:in `request'
	 3: from /Users/rahim/.rbenv-arm/versions/2.7.2/lib/ruby/gems/2.7.0/gems/excon-0.103.0/lib/excon/connection.rb:291:in `request'
	 2: from /Users/rahim/.rbenv-arm/versions/2.7.2/lib/ruby/gems/2.7.0/gems/excon-0.103.0/lib/excon/connection.rb:460:in `response'
	 1: from /Users/rahim/.rbenv-arm/versions/2.7.2/lib/ruby/gems/2.7.0/gems/excon-0.103.0/lib/excon/middlewares/response_parser.rb:12:in `response_call'
/Users/rahim/.rbenv-arm/versions/2.7.2/lib/ruby/gems/2.7.0/gems/excon-0.103.0/lib/excon/middlewares/expects.rb:13:in `response_call': Expected(200) <=> Actual(403 Forbidden) (Excon::Error::Forbidden)
excon.error.response
  :body              => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Error><Code>SignatureDoesNotMatch</Code><Message>The request signature we calculated does not match the signature you provided. Check your key and signing method.</Message><AWSAccessKeyId>AKIA4EAE47NL3ELESEWF</AWSAccessKeyId><StringToSign>AWS4-HMAC-SHA256\n20230922T113221Z\n20230922/us-east-1/s3/aws4_request\n570839a873303488b9dac5ba94a5e6d56a7f9a494a2e65d9defba2a523e37547</StringToSign><SignatureProvided>2fd1570ad79c7ef2a6ffcbb91fcd562f62cb77f8b027601033657ac1d8a6c261</SignatureProvided><StringToSignBytes>41 57 53 34 2d 48 4d 41 43 2d 53 48 41 32 35 36 0a 32 30 32 33 30 39 32 32 54 31 31 33 32 32 31 5a 0a 32 30 32 33 30 39 32 32 2f 75 73 2d 65 61 73 74 2d 31 2f 73 33 2f 61 77 73 34 5f 72 65 71 75 65 73 74 0a 35 37 30 38 33 39 61 38 37 33 33 30 33 34 38 38 62 39 64 61 63 35 62 61 39 34 61 35 65 36 64 35 36 61 37 66 39 61 34 39 34 61 32 65 36 35 64 39 64 65 66 62 61 32 61 35 32 33 65 33 37 35 34 37</StringToSignBytes><CanonicalRequest>PUT\n/foo\n\ncontent-length:3\ncontent-type:\nhost:rahim-throwaway-us-east-1.s3.amazonaws.com\nx-amz-content-sha256:fcde2b2edba56bf408601fb721fe9b5c338d10ee429ea04fae5511b68fbf8fb9\nx-amz-date:20230922T113221Z\nx-amz-id-2:\nx-amz-request-id:\nx-amz-server-side-encryption:AES256\n\ncontent-length;content-type;host;x-amz-content-sha256;x-amz-date;x-amz-id-2;x-amz-request-id;x-amz-server-side-encryption\nfcde2b2edba56bf408601fb721fe9b5c338d10ee429ea04fae5511b68fbf8fb9</CanonicalRequest><CanonicalRequestBytes>50 55 54 0a 2f 66 6f 6f 0a 0a 63 6f 6e 74 65 6e 74 2d 6c 65 6e 67 74 68 3a 33 0a 63 6f 6e 74 65 6e 74 2d 74 79 70 65 3a 0a 68 6f 73 74 3a 72 61 68 69 6d 2d 74 68 72 6f 77 61 77 61 79 2d 75 73 2d 65 61 73 74 2d 31 2e 73 33 2e 61 6d 61 7a 6f 6e 61 77 73 2e 63 6f 6d 0a 78 2d 61 6d 7a 2d 63 6f 6e 74 65 6e 74 2d 73 68 61 32 35 36 3a 66 63 64 65 32 62 32 65 64 62 61 35 36 62 66 34 30 38 36 30 31 66 62 37 32 31 66 65 39 62 35 63 33 33 38 64 31 30 65 65 34 32 39 65 61 30 34 66 61 65 35 35 31 31 62 36 38 66 62 66 38 66 62 39 0a 78 2d 61 6d 7a 2d 64 61 74 65 3a 32 30 32 33 30 39 32 32 54 31 31 33 32 32 31 5a 0a 78 2d 61 6d 7a 2d 69 64 2d 32 3a 0a 78 2d 61 6d 7a 2d 72 65 71 75 65 73 74 2d 69 64 3a 0a 78 2d 61 6d 7a 2d 73 65 72 76 65 72 2d 73 69 64 65 2d 65 6e 63 72 79 70 74 69 6f 6e 3a 41 45 53 32 35 36 0a 0a 63 6f 6e 74 65 6e 74 2d 6c 65 6e 67 74 68 3b 63 6f 6e 74 65 6e 74 2d 74 79 70 65 3b 68 6f 73 74 3b 78 2d 61 6d 7a 2d 63 6f 6e 74 65 6e 74 2d 73 68 61 32 35 36 3b 78 2d 61 6d 7a 2d 64 61 74 65 3b 78 2d 61 6d 7a 2d 69 64 2d 32 3b 78 2d 61 6d 7a 2d 72 65 71 75 65 73 74 2d 69 64 3b 78 2d 61 6d 7a 2d 73 65 72 76 65 72 2d 73 69 64 65 2d 65 6e 63 72 79 70 74 69 6f 6e 0a 66 63 64 65 32 62 32 65 64 62 61 35 36 62 66 34 30 38 36 30 31 66 62 37 32 31 66 65 39 62 35 63 33 33 38 64 31 30 65 65 34 32 39 65 61 30 34 66 61 65 35 35 31 31 62 36 38 66 62 66 38 66 62 39</CanonicalRequestBytes><RequestId>Q803X9PKQY923EA9</RequestId><HostId>Y8WoSA7F4UdYUj80wzNuPnkHKxsUVKSpfI1d5F2+Hb0bN7mCJmpSaGpULFxVgMkn9GFI8cZS4HI=</HostId></Error>"
  :cookies           => [
  ]
  :headers           => {
    "Connection"       => "close"
    "Content-Type"     => "application/xml"
    "Date"             => "Fri, 22 Sep 2023 11:32:21 GMT"
    "Server"           => "AmazonS3"
    "x-amz-id-2"       => "Y8WoSA7F4UdYUj80wzNuPnkHKxsUVKSpfI1d5F2+Hb0bN7mCJmpSaGpULFxVgMkn9GFI8cZS4HI="
    "x-amz-request-id" => "Q803X9PKQY923EA9"
  }
  :host              => "rahim-throwaway-us-east-1.s3.amazonaws.com"
  :local_address     => "192.168.50.233"
  :local_port        => 65419
  :method            => "PUT"
  :omit_default_port => false
  :path              => "/foo"
  :port              => 443
  :query             => nil
  :reason_phrase     => "Forbidden"
  :remote_ip         => "52.216.207.139"
  :scheme            => "https"
  :status            => 403
  :status_line       => "HTTP/1.1 403 Forbidden\r\n"
```

## Notes

- region seems to matter, I've only seen the problem S3 behaviour in us-east-1
- something about location of caller seems to change probabilities significantly (perhaps latency related). With default retry behaviour, from my UK based laptop probability of a rejection seems _much_ lower than from a host within us-east-1, taking many hundreds of tries before a rejection from my laptop, but often 10s or less from an EC2 instance in us-east-1. Removing retries makes reproduction much faster in both cases.
