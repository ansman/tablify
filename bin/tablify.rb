#!/usr/bin/env ruby

if ARGV.empty?
  puts 'Usage: tablify.rb <file> [pixel_size]'
  exit
end

require 'RMagick'
require 'Haml'
include Magick

class Magick::Pixel
  def to_hex; to_i.to_s(16) end
  def to_i; (normalize(red) << 16) + (normalize(green) << 8) + normalize(blue) end
  def normalize(c); c * 2**8 / 2**16 end
end

image = ImageList.new(ARGV[0])
image.new_image(image.first.columns, image.first.rows) { self.background_color = "white" }
image = image.reverse.flatten_images

f = File.join(File.dirname(__FILE__), '..', 'templates', 'template.haml')
s = Haml::Engine.new(File.open(f).read)
rendered = s.render Object.new, {image: image, name: File.basename(ARGV[0]), size: (ARGV[1] or 8).to_i}
puts rendered.gsub(/\n\s+/, '')
