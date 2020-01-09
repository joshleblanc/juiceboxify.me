require 'sinatra'
require 'mini_magick'
require 'rest-client'
require 'dotenv/load'
require 'digest/sha1'
require "aws-sdk-s3"
require_relative './lib/azure/face'
require_relative './lib/amazon/s3'
require_relative './lib/utilities'

if development?
    require 'byebug'
end

include Utilities

get '/' do
    if params[:url]
        begin
            filename = juiceboxify(params[:url])
            if filename
                @path = "https://juiceboxify.sfo2.cdn.digitaloceanspaces.com/#{filename}"
            else
                @not_found = true
            end
        rescue StandardError => e
            p e.message
            @not_found = true
        end
        erb :index
    else
        erb :index
    end
end

get '/api' do
    RestClient.post("sa.juiceboxify.me/app", JSON.generate({ ua: request.user_agent, url: request.url })) do |resp, _, _|
        if resp.code == 301
            resp.follow_redirection
        else
            resp.return!
        end
    end
    headers 'Access-Control-Allow-Origin' => '*' 
    content_type 'application/json'
    if params[:url]
        begin
            filename = juiceboxify(params[:url])
            if filename
                content_type 'image/jpeg'
                response = RestClient::Request.execute(method: :get, url: "https://juiceboxify.sfo2.cdn.digitaloceanspaces.com/#{filename}", raw_response: true)
                send_file response.file, disposition: :inline, type: "image/jpeg"
            else
                JSON.generate({
                    error: "No faces detected"
                })
            end
        rescue StandardError => e
            p e.message
            JSON.generate({
                error: "No faces detected"
            })
        end
    else
        JSON.generate({
            error: "No URL provided"
        })
    end
end
