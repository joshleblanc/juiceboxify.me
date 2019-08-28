require 'sinatra'
require 'mini_magick'
require 'rest-client'
require 'dotenv/load'
require_relative './lib/azure/face'
require_relative './lib/utilities'

include Utilities

get '/' do
    if params[:url]
        filename = juiceboxify(params[:url])
        if filename
            @path = "images/#{filename}"
        else
            @not_found = true
        end
        erb :index
    else
        erb :index
    end
end

post '/' do
    redirect_to "?url=#{params[:url]}"
end

get '/api' do
    if params[:url]
        filename = juiceboxify(params[:url])
        if filename
            send_file File.join(Dir.pwd, "public/images/#{filename}"), disposition: :inline, type: "image/jpeg"
        else
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