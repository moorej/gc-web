require 'date'
require 'gruff'
require 'rmagick'
include Magick

class Chart
  attr_accessor :composite

  def initialize(blue, red, text)
    @composite = generate_chart(blue, red, text)
  end

  def to_blob
      @composite.to_blob
  end
  
  def generate_chart(blue, red, text)
    g = Gruff::SideStackedBar.new('383x21')
    g.hide_legend = g.hide_title = g.hide_line_markers  = hide_line_numbers = true
    g.top_margin = g.bottom_margin = g.left_margin = g.right_margin = g.title_margin = g.legend_margin =  0
    g.data(:blue, [blue], '#09519e')

    if red > -1
        g.data(:red, [red], '#8b0804')
    end

    il = ImageList.new
    il.from_blob(g.to_blob)
    txt = Draw.new

    il.annotate(txt, 0,0,0,3, text){
        txt.gravity = Magick::CenterGravity
        txt.pointsize = 12
        txt.fill = '#ffffff'
        txt.font_weight = 600
    }

    il.crop!(0, 4, 382, 18)
    il
  end

end