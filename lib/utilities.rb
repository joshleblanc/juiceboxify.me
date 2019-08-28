module Utilities
    def images_path
        File.join(Dir.pwd, "public/images")
    end

    # Age of a file in days
    def file_age(path) 
        (Time.now - File.stat(path).mtime).to_i / 86400.0
    end
    
    # Delete files older than a day
    def delete_old_images
        Dir["#{images_path}/*.*"].each do |path|
            File.delete(path) if file_age(path) > 1
        end
    end

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
                upper_lip_bottom = face_landmarks['upperLipBottom']
                under_lip_top = face_landmarks['underLipTop']
                mouth_middle = {
                    x: mouth_left['x'] + (mouth_right['x'] - mouth_left['x']) / 2,
                    y: upper_lip_bottom['y'] + (under_lip_top['y'] - upper_lip_bottom['y']) / 2
                }
        
                width = (pupil_right['x'] - pupil_left['x'])
                juicebox.resize "#{width}x"
                
                base_image = base_image.composite(juicebox) do |c|
                    c.compose "Over"
                    # I'm guessing the straw's tip is 7% below the top of the image
                    c.geometry "+#{mouth_middle[:x]}+#{mouth_middle[:y] - (juicebox.height * 0.07)}" 
                end
            end
    
            name = File.basename(base_image.tempfile.path)
            delete_old_images
            base_image.tempfile.open
            content = base_image.tempfile.read
            File.open(File.join(images_path, name), 'wb') do |file|
                file.write(content)
            end
            name
        end
    end
end