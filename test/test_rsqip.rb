require 'minitest/autorun'
require 'rsqip'

class RsqipTest < Minitest::Test
  FILENAME = 'test/monkey-selfie.jpg'.freeze

  PRIMITIVE = %(<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="512" height="709">
                  <rect x="0" y="0" width="512" height="709" fill="#596135" />
                    <g transform="scale(2.769531) translate(0.5 0.5)">
                    <polygon fill="#000000" fill-opacity="0.501961" points="-16,271 151,215 28,81" />
                    <polygon fill="#afbd68" fill-opacity="0.501961" points="200,-9 -16,-11 181,205" />
                    <polygon fill="#000006" fill-opacity="0.501961" points="64,65 176,91 101,42" />
                    <polygon fill="#05030b" fill-opacity="0.501961" points="153,119 -16,127 78,271" />
                    <polygon fill="#a1bc3d" fill-opacity="0.501961" points="-16,133 4,-16 153,-9" />
                    <polygon fill="#b1c247" fill-opacity="0.501961" points="200,154 162,6 131,238" />
                    <polygon fill="#81789e" fill-opacity="0.501961" points="92,146 154,103 66,59" />
                    <polygon fill="#0c0e0b" fill-opacity="0.501961" points="66,271 72,44 -16,186" />
                  </g>
                </svg>).freeze

  SVGO = %(<svg xmlns="http://www.w3.org/2000/svg" width="512" height="709"><path fill="#596135" d="M0 0h512v709H0z"/><g fill-opacity=".5"><path d="M-43 752l462.6-155.2-340.7-371z"/><path fill="#afbd68" d="M555.3-23.5L-43-29.1l545.6 598.2z"/><path fill="#000006" d="M178.6 181.4l310.2 72-207.7-135.7z"/><path fill="#05030b" d="M425.1 331l-468 22.1L217.4 752z"/><path fill="#a1bc3d" d="M-43 369.7L12.6-42.9 425-23.5z"/><path fill="#b1c247" d="M555.3 427.9L450 18l-85.8 642.5z"/><path fill="#81789e" d="M256.2 405.7l171.7-119-243.7-122z"/><path fill="#0c0e0b" d="M184.2 752l16.6-628.8L-43 516.5z"/></g></svg>).freeze

  FINAL_SVG = %(<svg xmlns="http://www.w3.org/2000/svg"viewBox="0 0 512 709"><filter id="b"><feGaussianBlur stdDeviation="12" /></filter><path fill="#596135" d="M0 0h512v709H0z"/><g filter="url(#b)" fill-opacity=".5"><path d="M-43 752l462.6-155.2-340.7-371z"/><path fill="#afbd68" d="M555.3-23.5L-43-29.1l545.6 598.2z"/><path fill="#000006" d="M178.6 181.4l310.2 72-207.7-135.7z"/><path fill="#05030b" d="M425.1 331l-468 22.1L217.4 752z"/><path fill="#a1bc3d" d="M-43 369.7L12.6-42.9 425-23.5z"/><path fill="#b1c247" d="M555.3 427.9L450 18l-85.8 642.5z"/><path fill="#81789e" d="M256.2 405.7l171.7-119-243.7-122z"/><path fill="#0c0e0b" d="M184.2 752l16.6-628.8L-43 516.5z"/></g></svg>).freeze

  SVG_BASE64ENCODED = 'PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcidmlld0JveD0iMCAwIDUxMiA3MDkiPjxmaWx0ZXIgaWQ9ImIiPjxmZUdhdXNzaWFuQmx1ciBzdGREZXZpYXRpb249IjEyIiAvPjwvZmlsdGVyPjxwYXRoIGZpbGw9IiM1OTYxMzUiIGQ9Ik0wIDBoNTEydjcwOUgweiIvPjxnIGZpbHRlcj0idXJsKCNiKSIgZmlsbC1vcGFjaXR5PSIuNSI+PHBhdGggZD0iTS00MyA3NTJsNDYyLjYtMTU1LjItMzQwLjctMzcxeiIvPjxwYXRoIGZpbGw9IiNhZmJkNjgiIGQ9Ik01NTUuMy0yMy41TC00My0yOS4xbDU0NS42IDU5OC4yeiIvPjxwYXRoIGZpbGw9IiMwMDAwMDYiIGQ9Ik0xNzguNiAxODEuNGwzMTAuMiA3Mi0yMDcuNy0xMzUuN3oiLz48cGF0aCBmaWxsPSIjMDUwMzBiIiBkPSJNNDI1LjEgMzMxbC00NjggMjIuMUwyMTcuNCA3NTJ6Ii8+PHBhdGggZmlsbD0iI2ExYmMzZCIgZD0iTS00MyAzNjkuN0wxMi42LTQyLjkgNDI1LTIzLjV6Ii8+PHBhdGggZmlsbD0iI2IxYzI0NyIgZD0iTTU1NS4zIDQyNy45TDQ1MCAxOGwtODUuOCA2NDIuNXoiLz48cGF0aCBmaWxsPSIjODE3ODllIiBkPSJNMjU2LjIgNDA1LjdsMTcxLjctMTE5LTI0My43LTEyMnoiLz48cGF0aCBmaWxsPSIjMGMwZTBiIiBkPSJNMTg0LjIgNzUybDE2LjYtNjI4LjhMLTQzIDUxNi41eiIvPjwvZz48L3N2Zz4='.freeze

  def test_dimensions
    assert_equal [512, 709], Rsqip.new(FILENAME).img_dimensions
  end

  def test_split_basename_extension
    assert_equal ['monkey-selfie', 'jpg'], Rsqip.new(nil).split_basename_extension(FILENAME)
  end

  def test_new_tmpname
    assert_equal false, (Rsqip.new(nil).new_tmpname(FILENAME) =~ /(.?)monkey-selfie(.+)jpg/).nil?
  end

  def test_geometry_of
    assert_equal 111, Rsqip.new(nil).geometry_of(99, 111)
    assert_equal 222, Rsqip.new(nil).geometry_of(222, 88)
  end

  def test_initialize
    assert_equal 8, Rsqip.new(nil).instance_variable_get('@number_of_primitives')
    assert_equal 11, Rsqip.new(nil, number_of_primitives: 11).instance_variable_get('@number_of_primitives')
    assert_equal FILENAME, Rsqip.new(FILENAME).instance_variable_get('@input_filename')
  end

  def test_run_primitive
    o = FILENAME + '-primitive-output.svg'
    Rsqip.new(nil).run_primitive(FILENAME, o, 8, 709)
    svg = File.read(o)
    File.delete(o)

    assert_equal true, svg.include?('<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="512" height="709">')
  end

  def test_run_svgo
    i = FILENAME + '-primitive-output.svg'
    o = FILENAME + '-svgo-output.svg'

    File.write(i, PRIMITIVE)

    Rsqip.new(nil).run_svgo(i, o)
    svg = File.read(o)

    File.delete(i)
    File.delete(o)

    assert_equal true, svg == SVGO
  end

  def test_replace_attrs
    svg = Rsqip.new(nil).replace_attrs(SVGO, 512, 709)
    assert_equal true, svg == FINAL_SVG
  end

  def test_as_hash
    rsqip = Rsqip.new(nil)
    rsqip.instance_variable_set('@img_dimensions', [512, 709])
    rsqip.instance_variable_set('@final_svg', FINAL_SVG)
    rsqip.instance_variable_set('@svg_base64encoded', SVG_BASE64ENCODED)

    h = { img_dimensions: [512, 709],
          final_svg: FINAL_SVG,
          svg_base64encoded: SVG_BASE64ENCODED }

    assert_equal h, rsqip.as_hash
  end

  def test_svg_base64encoded
    rsqip = Rsqip.new(nil)
    rsqip.instance_variable_set('@final_svg', FINAL_SVG)

    assert_equal SVG_BASE64ENCODED, rsqip.svg_base64encoded
  end

  def test_final_svg
    rsqip = Rsqip.new(nil)
    rsqip.instance_variable_set('@img_dimensions', [512, 709])

    svgo = FILENAME + '-svgo-output.svg'
    File.write(svgo, SVGO)
    rsqip.instance_variable_set('@svgo_output_filename', svgo)

    final_svg = rsqip.final_svg
    File.delete(svgo)

    assert_equal FINAL_SVG, final_svg
  end

  def test_new_run
    rsqip = Rsqip.new(FILENAME).run

    primitive = rsqip.instance_variable_get('@primitive_output_filename')
    svgo = rsqip.instance_variable_get('@svgo_output_filename')

    primitive_svg = File.read(primitive)
    svgo_svg = File.read(svgo)

    File.delete(primitive)
    File.delete(svgo)

    assert_equal true, primitive_svg.include?('<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="512" height="709">')
    assert_equal true, svgo_svg.include?('<svg xmlns="http://www.w3.org/2000/svg" width="512" height="709">')
  end
end
