module Utilities
    def juiceboxify(url)
        data = Azure::Face.detect(url, { returnFaceLandmarks: true })
        if data.empty?
            return nil
        else
            base_image = MiniMagick::Image.open(url)
            juicebox = MiniMagick::Image.open(File.join(Dir.pwd, "assets/juicebox.png"))
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
    
            name = File.basename(base_image.tempfile.path)
            base_image.write(File.join(Dir.pwd, "public/images/#{name}"))
            name
        end
    end
end