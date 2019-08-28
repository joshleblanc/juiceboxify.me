require 'sinatra'

get '/' do
    if request.accept? 'application/json'
        if params[:url]

        else
            JSON.generate({
                error: "No URL provided"
            })
        end
    else
        if params[:url]

        else
            erb :index
        end
    end
end