# frozen_string_literal: true

require 'aws-sdk-s3'

class S3Client
  attr_reader :client
  def initialize
    @client = Aws::S3::Client.new(
      access_key_id: ENV['DO_SPACES_KEY'],
      secret_access_key: ENV['DO_SPACES_SECRET'],
      endpoint: 'https://nyc3.digitaloceanspaces.com',
      region: 'us-east-1'
    )
  end

  def create_bucket(name)
    client.create_bucket({
                           bucket: name
                         })
  end

  def write_private(bucket:, key:, body:)
    client.put_object({
                        bucket: bucket,
                        key: key,
                        body: body,
                        acl: 'private'
                      })
  end

  def read(bucket:, key:)
    client.get_object({
                        bucket: bucket,
                        key: key
                      }).string
  end
end
