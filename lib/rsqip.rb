require 'tempfile'
require 'base64'
require 'dimensions'

class Rsqip
  # Example:
  #   >> Rsqip.new('/tmp/picture.png').run.final_svg
  #   => <svg ...
  #
  #   >> Rsqip.new('/tmp/picture.png').run.svg_base64encoded
  #   => PHN2ZyB4bWxucz0ia ...
  #
  #   >> Rsqip.new('/tmp/picture.png').run.as_hash
  #   => { img_dimensions: [300, 100],
  #        final_svg: '<?xml version="1.0"?><svg ...',
  #        svg_base64encoded: 'PHN2ZyB4bWxucz0ia ...' }
  #
  def initialize(input_filename, number_of_primitives: 8)
    @input_filename = input_filename
    @number_of_primitives = number_of_primitives

    unless system('type', 'primitive')
      raise 'Please ensure that Primitive (https://github.com/fogleman/primitive, written in Golang) is installed and globally available'
    end

    unless system('type', 'svgo')
      raise 'Please ensure that Svgo (https://github.com/svg/svgo, written in Nodejs) is installed and globally available'
    end
  end

  def run
    @primitive_output_filename = new_tmpname(@input_filename) + '.svg'
    run_primitive(@input_filename,
                  @primitive_output_filename,
                  @number_of_primitives,
                  geometry_of(*img_dimensions))

    @svgo_output_filename = new_tmpname(@input_filename) + '.svg'
    run_svgo(@primitive_output_filename, @svgo_output_filename)

    self
  end

  def img_dimensions
    @img_dimensions ||= Dimensions.dimensions(@input_filename)
  end

  def final_svg
    @final_svg ||= replace_attrs(File.read(@svgo_output_filename), *img_dimensions)
  end

  def svg_base64encoded
    @svg_base64encoded ||= Base64.encode64(@final_svg).delete("\n")
  end

  def as_hash
    { img_dimensions: img_dimensions,
      final_svg: final_svg,
      svg_base64encoded: svg_base64encoded }
  end

  # filenames and picture size
  # utilities
  #
  def new_tmpname(filename)
    Dir::Tmpname.make_tmpname(*split_basename_extension(filename))
  end

  def split_basename_extension(filename)
    fparts = filename.split('/').last.split('.')
    [fparts[0..-2].join('.'), fparts.last]
  end

  def geometry_of(width, height)
    width > height ? width : height
  end

  # binary interfaces
  # to primitive and svgo
  #
  def run_primitive(input, output, number_of_primitives, size)
    system('primitive',
           '-i', input,
           '-o', output,
           '-n', number_of_primitives.to_s,
           '-m', '0',
           '-s', size.to_s)
  end

  def run_svgo(input, ouput)
    system('svgo',
           input,
           '--multipass',
           '-p', '1',
           '-o', ouput)
  end

  # Add viewbox and preserveAspectRatio attributes
  # as well as a Gaussian Blur filter to the SVG
  #
  # original comment:
  # We initially worked with a proper DOM parser to
  # manipulate the SVG's XML, but it was very opinionated
  # about SVG syntax and kept introducing unwanted tags.
  # So we had to resort to RegEx replacements
  def replace_attrs(svg, width, height)
    ratio = '<svg xmlns="http://www.w3.org/2000/svg"' +
            %(viewBox="0 0 #{width} #{height}">)
    blur = '<filter id="b"><feGaussianBlur stdDeviation="12" /></filter>'
    svg.sub(/(<svg)(.*?)(>)/, ratio + blur)
       .gsub(/(<g)/, '<g filter="url(#b)"')
  end
end
