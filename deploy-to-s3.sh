
export AWS_DEFAULT_PROFILE=3dr
aws s3 mb s3://www.droneshare.com
aws s3 sync --delete dist s3://www.droneshare.com
aws s3api put-bucket-website --bucket www.droneshare.com --website-configuration file://s3website.json
aws s3api put-bucket-policy --bucket www.droneshare.com --policy file://s3bucket-policy.json
