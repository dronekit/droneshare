
BUCKETNAME=alpha.droneshare.com
export AWS_DEFAULT_PROFILE=3dr
aws s3 mb s3://$BUCKETNAME
aws s3 sync --delete dist s3://$BUCKETNAME

cat >s3website.json <<EOF
{

  "IndexDocument": {
    "Suffix": "index.html"
    },
    "RoutingRules": [
    {
      "Condition": {
        "HttpErrorCodeReturnedEquals": "404"
        },

        "Redirect": {
          "ReplaceKeyWith": "index.html"
        }
      }
      ]
    }
EOF

aws s3api put-bucket-website --bucket $BUCKETNAME --website-configuration file://s3website.json

cat > s3bucket-policy.json <<EOF
{
  "Version":"2012-10-17",
  "Statement":[{
  "Sid":"PublicReadGetObject",
        "Effect":"Allow",
    "Principal": {
            "AWS": "*"
         },
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::$BUCKETNAME/*"
      ]
    }
  ]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKETNAME --policy file://s3bucket-policy.json
echo Completed deployment
