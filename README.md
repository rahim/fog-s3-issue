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
```

## Notes

- region seems to matter, I've only seen the problem S3 behaviour in us-east-1
- something about location of caller seems to change probabilities significantly (perhaps latency related). From my UK based laptop probability of a rejection seems _much_ lower than from a host within us-east-1, taking many hundreds of tries before a rejection from my laptop, but often 10s or less from an EC2 instance in us-east-1.
