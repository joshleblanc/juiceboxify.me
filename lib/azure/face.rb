module Azure
    class Face
        class << self
            @@base_url = "https://westcentralus.api.cognitive.microsoft.com/face/v1.0/"
            @@headers = {
                'Ocp-Apim-Subscription-Key': Rails.application.credentials.azure_face_api_key,
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
                response = RestClient.post("#{@@base_url}detect", JSON.generate(body), headers)
                JSON.parse(response.body)
            end
        end
    end
end