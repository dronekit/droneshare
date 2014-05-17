
BUCKETNAME=www.droneshare.com
export AWS_DEFAULT_PROFILE=3dr
aws s3 mb s3://$BUCKETNAME
aws s3 sync --delete dist s3://$BUCKETNAME
aws s3api put-bucket-website --bucket $BUCKETNAME --website-configuration file://s3website.json
aws s3api put-bucket-policy --bucket $BUCKETNAME --policy file://s3bucket-policy.json
echo Completed deployment
