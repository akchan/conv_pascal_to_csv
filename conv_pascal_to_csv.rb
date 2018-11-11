#!/usr/bin/env ruby

# Created on 2018/09/30 Sun
# 
# Convert annotation file and images of Pascal VOC format to csv format for keras-retinanet
# For detail of csv format, see https://github.com/fizyr/keras-retinanet
# 
# [Usage]
# 
# ```sh
# ruby conv_pascal_to_csv.rb --annotation-path PATH_TO_ANNOTATION --image-path PATH_TO_IMAGES
# ```
#
# [Result]
# 
# - This script makes csv and images directory to current directory.
# 


require 'optparse'
require 'fileutils'
require 'pathname'
require 'csv'
require 'rexml/document'



opt = {
  path: {
    annotation: nil,
    src_images: nil,
    dest_images: Pathname.new(File.absolute_path('./images')),
    csv: Pathname.new(File.absolute_path('./csv')),
  },
  val_ratio: 0.1
}

opt_parse = OptionParser.new
opt_parse.on('--annotation-path PATH', 'path to xml annotations directory') {|v| opt[:path][:annotation] = Pathname.new(File.absolute_path(v)) }
opt_parse.on('--image-path PATH', 'path to jpeg images directory') {|v| opt[:path][:src_images] = Pathname.new(File.absolute_path(v)) }
opt_parse.on('--val-ratio float', 'sample ratio for validation (0.0 - 1.0). default=0.1') {|v| opt[:val_ratio] = v.to_f}
opt_parse.parse!(ARGV)



def open_and_parse_xml(path)
  str = IO.read(path, nil, mode: 'rt', encoding: 'UTF-8')
  xml = REXML::Document.new(str)

  objects = REXML::XPath.match(xml, "/annotation/object").map { |obj|
    x1, y1, x2, y2 = %w[xmin ymin xmax ymax].map{|i|
      obj.elements["bndbox"].elements[i].text
    }
    class_name = obj.elements["name"].text

    [x1, y1, x2, y2, class_name]
  }

  objects
end



# Copying images
# 
if not Dir.exist?(opt[:path][:dest_images])
  Dir.mkdir(opt[:path][:dest_images])
end

images_path = Dir.glob(opt[:path][:src_images] + '*.jpg')
if opt[:path][:src_images] =! opt[:path][:dest_images]  
  images_path.each do |src_img_path|
    puts "Copying image file: #{src_img_path}"
    FileUtils.cp(src_img_path, opt[:path][:dest_images])
  end
end



# Creating annotation, validation, and classes csv
# 
used_images = images_path.map{|p| [File.basename(p, '.jpg'), false] }.to_h
classes = []

objects = Dir.glob(opt[:path][:annotation] + '*.xml').map {|path_xml|
  basename = File.basename(path_xml, '.xml')
  path_jpg = opt[:path][:dest_images].relative_path_from(opt[:path][:csv]) + "#{basename}.jpg"

  objects = open_and_parse_xml(path_xml).map {|x1, y1, x2, y2, class_name|
    classes << class_name
    [path_jpg, x1, y1, x2, y2, class_name]
  }

  used_images[basename] = true

  objects
}.shuffle

n_val = (images_path.size * opt[:val_ratio]).floor
objects_val = objects.pop(n_val)

classes = classes.uniq
objects = objects.flatten(1).sort_by{|path_jpg, x1, y1, x2, y2, class_name| [path_jpg, x1] }
objects_val = objects_val.flatten(1).sort_by{|path_jpg, x1, y1, x2, y2, class_name| [path_jpg, x1] }

un_used_images = used_images.select{|basename, flag|
                              flag == false
                            }
                            .map{|basename, flag|
                              relative_path = opt[:path][:dest_images].relative_path_from(opt[:path][:csv]) + "#{basename}.jpg"
                              [relative_path, "", "", "", "", ""]
                            }

if not Dir.exist?(opt[:path][:csv])
  Dir.mkdir(opt[:path][:csv])
end

Dir.chdir(opt[:path][:csv]) do
  file_an = 'annotations.csv'
  CSV.open(file_an, 'w') do |csv|
    puts "Creating #{file_an}"
    objects.each do |object|
      csv << object
    end

    un_used_images.each do |object|
      csv << object
    end
  end

  file_val = 'val_annotations.csv'
  CSV.open(file_val, "w") do |csv|
    puts "Creating #{file_val}"
    objects_val.each do |object|
      csv << object
    end
  end

  file_class = 'classes.csv'
  CSV.open(file_class, 'w') do |csv|
    puts "Creating #{file_class}"
    classes.each.with_index do |c, i|
      csv << [c, i]
    end
  end
end

puts "Done"
