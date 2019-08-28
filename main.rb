require 'sinatra'
require 'mini_magick'
require 'rest-client'
require_relative './lib/azure/face'

def api_call?
    request.accept? 'application/json'
end

def index
    if api_call?
        JSON.generate({
            error: "No URL provided"
        })
    else
        erb :index
    end
end

def process
    data = Azure::Face.detect(params[:url], { returnFaceLandmarks: true })
    if data.empty?
        if api_call? 
            JSON.generate({ error: "No faces detected" })
        else
            "No faces detected"
        end
    else
        base_image = MiniMagick::Image.open(params[:url])
        juicebox = MiniMagick::Image.open(File.join(Dir.pwd, "app/assets/juicebox.png"))
        data.each do |datum|
            face_landmarks = datum['faceLandmarks']
            pupil_left = face_landmarks['pupilLeft']
            pupil_right = face_landmarks['pupilRight']
            mouth_left = face_landmarks['mouthLeft']
            mouth_right = face_landmarks['mouthRight']
            mouth_middle = {
                x: mouth_left['x'] + (mouth_right['x'] - mouth_left['x']) / 2,
                y: [mouth_right['y'], mouth_left['y']].min + (mouth_right['y'] - mouth_left['y']) / 2
            }
    
            width = (pupil_right['x'] - pupil_left['x']) * 1.5
            scale = juicebox.width / width

            juicebox.resize "#{width}x#{juicebox.height * scale}"
            
            base_image = base_image.composite(juicebox) do |c|
                c.compose "Over"
                c.geometry "+#{mouth_middle[:x]}+#{mouth_middle[:y]}"
            end
        end

        public_path 
        base_image.write(File.join(Dir.pwd, "public/images/#{base_image.tempfile.filename}"))
        
    end
end

get '/' do
    if params[:url]
        process
    else
        index
    end
end