module Amazon
  class S3
    class << self
      def client
        @client ||= Aws::S3::Client.new(
            access_key_id: ENV['aws_access_key_id'],
            secret_access_key: ENV['aws_secret_access_key'],
            endpoint: "https://sfo2.digitaloceanspaces.com",
            region: "sfo2"
        )
      end

      def exists(file_name)
        begin
          client.get_object(
              bucket: "juiceboxify",
              key: file_name,
          )
          true
        rescue
          false
        end
      end
      
      def upload(file, file_name)
        client.put_object({
                              body: file,
                              bucket: "juiceboxify",
                              key: file_name,
                              acl: "public-read",
                              content_type: "image/png"
                          })
      end
    end
  end
end