# Fog S3 header issue minimal reproduction

Run with

```
$ export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXX
$ export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXX
$ DEBUG=1 EXCON_DEBUG=1 ./repro_s3_issue.rb
```


Using

```
$ DEBUG=1 EXCON_DEBUG=1 ./repro_s3_issue.rb | grep "amz-id\|GET\|PUT\|excon.request\|excon.response"
excon.request
  :method              => "GET"
excon.response
    "x-amz-id-2"                   => "P2skC5+lf91t+6AigP9djm91TosoUcgT12qj+oPkApNRX5lK2bNIrPbFsHhpJwDS2rqwDuZovxk="
  :method            => "GET"
excon.request
  :method              => "PUT"
excon.response
    "x-amz-id-2"                   => "CVe7uzMMpgQeev21I8xpyuvm7XPQKr1R+BRpiUXwp1YH+a093d1y2MjljtsWl7Sc6N/MUbwI2qE="
  :method            => "PUT"
```

Can be useful for seeing just what we care about.

## Reproduction

What's different from our real world case? (part II)

./repro_s3_issue_iam.rb successfully reproduces on our staging host

- gem versions ✅
- ruby version ✅

- region? ✅

- host IP/location?
- bucket / bucket config?
- use of IAM profile?
- account?

Observation: that we see the ids in the initial response to the GET suggests we're hitting a different code path in our staging + production cases.

- could NewRelic be to blame?

Do we need to recheck our earlier reproduction steps in case AWS have fixed?
