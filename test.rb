require 'gruff'
require 'RMagick'
include Magick

g = Gruff::SideStackedBar.new('404x22')
g.hide_legend = g.hide_title = g.hide_line_markers = true
g.hide_line_numbers = false
g.top_margin = g.bottom_margin = g.left_margin = g.right_margin = 0
g.title_margin = g.legend_margin = 0

g.data(:days_down, [30], '#09519e')
g.data(:days_rem, [62], '#8b0804')

ilist = ImageList.new
ilist.from_blob(g.to_blob)
txt = Draw.new

ilist.crop!(Magick::CenterGravity, 400, 18)

ilist.annotate(txt, 0,0,4,0, "30"){
	txt.gravity = Magick::WestGravity
	txt.pointsize = 14
	# txt.stroke = '#000000'
	txt.fill = '#ffffff'
	txt.font_weight = Magick::BoldWeight
}

ilist.annotate(txt, 0,0,7,0, "62"){
	txt.gravity = Magick::EastGravity
	txt.pointsize = 14
	# txt.stroke = '#000000'
	txt.fill = '#ffffff'
	txt.font_weight = Magick::BoldWeight
}

ilist.write('chart.png')