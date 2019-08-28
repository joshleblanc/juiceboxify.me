require 'sinatra'
require 'mini_magick'
require 'rest-client'
require 'dotenv/load'
require_relative './lib/azure/face'
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
                @path = "images/#{filename}"
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
    headers 'Access-Control-Allow-Origin' => '*'
    if params[:url]
        begin
            filename = juiceboxify(params[:url])
            if filename
                send_file File.join(Dir.pwd, "public/images/#{filename}"), disposition: :inline, type: "image/jpeg"
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