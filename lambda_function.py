from __future__ import print_function

import boto3
import os
import urllib
import zipfile

print('Loading function')

s3 = boto3.client('s3')


def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    url = event['Records'][0]['s3']['object']['key'].encode('utf8')
    key = urllib.unquote_plus(url)
    s3_path = os.path.dirname(key)
    try:
        s3.download_file(bucket, key, '/tmp/target.zip')
        zfile = zipfile.ZipFile('/tmp/target.zip')
        namelist = zfile.namelist()
        for filename in namelist:
            data = zfile.read(filename)
            localpath = '/tmp/{}'.format(str(filename))
            f = open(localpath, 'wb')
            f.write(data)
            f.close()
            s3.upload_file(localpath, bucket, os.path.join(s3_path, filename))
        s3.delete_object(Bucket=bucket, Key=key)
        return "AWS Key -> {}".format(key)
    except Exception as e:
        print(e)
        raise e
