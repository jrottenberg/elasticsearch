Elasticsearch
=============

This repository contains **Dockerfile** of [ElasticSearch](http://www.elasticsearch.org/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/dockerfile/elasticsearch/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

Based on https://github.com/dockerfile/elasticsearch/

[Bigdesk](https://github.com/lukas-vlcek/bigdesk) and [cloud-aws](https://github.com/elasticsearch/elasticsearch-cloud-aws) plugins installed

Setup
-----

Create an IAM user with those policies for ec2 discovery and s3 snapshots (replace *BUCKET* with the bucket you will use).

### ec2 discovery

```
{
    "Statement": [
        {
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
```

### s3 snapshots

```
{
    "Statement": [
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::BUCKET"
            ]
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::BUCKET/*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
```

### User data

```
(cat << EOF

AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_KEY=yyy

ES_NAME=$(ec2metadata --instance-id)

AWS_SECURITY_GROUP=$(ec2metadata --security-groups)

AWS_PRIVATE_IP=$(ec2metadata --local-ipv4)

AWS_ZONE=$(ec2metadata --availability-zone)

AWS_REGION=${AWS_ZONE%%*([![:digit:]])}

EOF ) > /dev/shm/es


docker run -d --env-file=/dev/shm/es  -p 9200:9200 -p 9300:9300 jrottenberg/elasticsearch


```

Operations
----------

### Snapshot

[Elasticsearch snapshot](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-snapshots.html#_snapshot)

One time setup (credentials will come from the config) to prepare the s3 snapshot

```
curl -XPUT 'http://ELB:9200/_snapshot/s3' -d '
{
    "type": "s3",
    "settings": {
        "compress": true,
        "bucket": "<s3 bucket name>"
    }
}'
```

Take a snapshot :

```
curl -XPUT "http://ELB:9200/_snapshot/s3/$(date +%Y%M%d_%H%m)?wait_for_completion=true"


```

### List snapshots

```
curl -XPUT "http://ELB:9200/_snapshot/s3/_all?pretty=true"


```

### Restore

[Elasticsearch restore](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-snapshots.html#_restore)

```
curl -XPUT "http://ELB:9200/_snapshot/s3/SNAPSHOT_TO_RESTORE/restore?wait_for_completion=true"


```
