module Azure
    class Face
        class << self
            @@base_url = "https://juiceboxify.cognitiveservices.azure.com/face/v1.0/"
            @@headers = {
                'Ocp-Apim-Subscription-Key': ENV['azure_face_api_key'],
                'Content-Type': 'application/json'
            }

            def detect(url, opts = {})
                headers = {
                    **@@headers,
                    params: {
                        **opts
                    }
                }
                body = {
                    url: url
                }
                begin
                    response = RestClient.post("#{@@base_url}detect", JSON.generate(body), headers)
                    JSON.parse(response.body)
                rescue StandardError => e
                    p e.message
                    []
                end
            end
        end
    end
end