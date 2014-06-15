
set -e

SERVERNAME=$1

if [ -z "$SERVERNAME" ]; then
    echo "Usage: deploy-s3 <servername>"
    exit -1
fi

if [ "$SERVERNAME" != "alpha" -a "$SERVERNAME" != "beta" -a "$SERVERNAME" != "production" ]; then
    echo "Error, invalid server name"
    exit -1
fi

if [ $SERVERNAME = production ]; then
    read -p "Are you REALLY REALLY SURE? " yn
    case $yn in
        [Yy]* ) echo "deploying to production";;
        * ) exit -1;;
    esac
fi

# Kill any running dev server, then start a prod build
skill grunt
grunt prod

BUCKETNAME=$SERVERNAME.droneshare.com
export AWS_DEFAULT_PROFILE=3dr
aws s3 mb s3://$BUCKETNAME || true

# For now we limit cache time to 1hr
aws s3 sync --delete --cache-control="max-age=3600" dist s3://$BUCKETNAME

# AngularJS applications prefer to get back index.html for any bad links
cat >s3website.json <<EOF
{

  "IndexDocument": {
    "Suffix": "index.html"
    },

  "ErrorDocument": {
    "Key": "index.html"
    }
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

TAGNAME=deploy-$SERVERNAME-`date +%F-%H%M%S`
echo "Tagging new deployment: $TAGNAME"
git tag -a $TAGNAME -m deployed
git push --tags
