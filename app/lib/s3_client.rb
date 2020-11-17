# frozen_string_literal: true

require 'aws-sdk-s3'

class S3Client
  attr_reader :client
  def initialize(bucket, namespace = "")
    @bucket = bucket
    @namespace = namespace + '/'

    @client = Aws::S3::Client.new(
      access_key_id: ENV['DO_SPACES_KEY'],
      secret_access_key: ENV['DO_SPACES_SECRET'],
      endpoint: 'https://nyc3.digitaloceanspaces.com',
      region: 'us-east-1'
    )
  end

  def write_private(key:, body:)
    client.put_object({
                        bucket: @bucket,
                        key: @namespace + key.to_s,
                        body: body,
                        acl: 'private'
                      })
  end

  def read_json(key:)
    raw_json = read(key: key).body.read
    JSON.parse(raw_json)
  end

  def read(key:)
    client.get_object({
                        bucket: @bucket,
                        key: namespace + key
                      })
  end

end
