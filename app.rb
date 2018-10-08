require 'rubygems'
require 'sinatra'
require 'date'
require 'gruff'
require 'rmagick'
require 'open-uri'
include Magick


class App < Sinatra::Application

#	@@spade_img_urls = {
#		"SEEDLING"	=> "http://ficoforums.myfico.com/t5/image/serverpage/image-id/2760iB9166C1A493A3CBC",
#		"BRONZE"	=> "http://ficoforums.myfico.com/t5/image/serverpage/image-id/33673iA9327A27227FE439",
#		"SILVER"	=> "http://ficoforums.myfico.com/t5/image/serverpage/image-id/33675i85072060A7E9ED9F",
#		"GOLD"		=> "http://ficoforums.myfico.com/t5/image/serverpage/image-id/33674i6D97EA62D60FAA1E",
#		"PALLADIUM"	=> "http://ficoforums.myfico.com/t5/image/serverpage/image-id/5761iE36E284CEECEA414",
#		"PLATINUM"	=> "http://ficoforums.myfico.com/t5/image/serverpage/image-id/33676i7D22867F5B8C8548",
#		"RUBY"		=> "http://ficoforums.myfico.com/t5/image/serverpage/image-id/5625i09098E9833D7A4B2",
#		"EMERALT"	=> "http://ficoforums.myfico.com/t5/image/serverpage/image-id/5623i698C4BF1F9D77284",
#		"SAPPHIRE"	=> "http://ficoforums.myfico.com/t5/image/serverpage/image-id/5627iA714E0C3C98AD3FD",
#		"DIAMOND"	=> "http://ficoforums.myfico.com/t5/image/serverpage/image-id/33677iDA1FD49740EB050B"	
#	}


    def get_spade_status(hp_date)
        # returns has of status
        
        spade = {}
      
        today = Date.today

        # Grab the number of months the users been in the garden
        months = (today.year * 12 + today.month) - (hp_date.year * 12 + hp_date.month)
        if (hp_date.day > today.day)
            months -= 1
        end

        # This should be obvious...
        case months
        when 0
            spade[:id] = "SEEDLING"
            spade[:name] = "Seedling"
            spade[:days_down] = (today - hp_date).to_i
            spade[:days_until] = ((hp_date >> 1) - today).to_i
            spade[:img_url] = "images/#{spade[:id].downcase}.png"
        when 1..2
            spade[:id] = "BRONZE"
            spade[:name] =  "Bronze Spade"
            spade[:days_down] = (today - (hp_date >> 1)).to_i
            spade[:days_until] = ((hp_date >> 3) - today).to_i
            spade[:img_url] = @@spade_img_pade[:img_width] = 40
        when 3..5
            spade[:id] = "SILVER"
            spade[:name] = "Silver Spade"
            spade[:days_down] = (today - (hp_date >> 3)).to_i
            spade[:days_until] = ((hp_date >> 6) - today).to_i
            spade[:img_url] = "images/#{spade[:id].downcase}.png"
        when 6..8
            spade[:id] = "GOLD"
            spade[:name] = "Gold Spade"
            spade[:days_down] = (today - (hp_date >> 6)).to_i
            spade[:days_until] = ((hp_date >> 9) - today).to_i
            spade[:img_url] = "images/#{spade[:id].downcase}.png"
        when 9..11
            spade[:id] = "PALLADIUM"
            spade[:name] = "Palladium Spade"
            spade[:days_down] = (today - (hp_date >> 9)).to_i
            spade[:days_until] = ((hp_date >> 12) - today).to_i
            spade[:img_url] = "images/#{spade[:id].downcase}.png"
        when 12..14
        	spade[:id] = "PLATINUM"
            spade[:name] = "Platinum Spade"
            spade[:days_down] = (today - (hp_date >> 12)).to_i
            spade[:days_until] = ((hp_date >> 15) - today).to_i
            spade[:img_url] = "images/#{spade[:id].downcase}.png"
        when 15..17
        	spade[:id] = "RUBY"
            spade[:name] = "Ruby"
            spade[:days_down] = (today - (hp_date >> 15)).to_i
            spade[:days_until] = ((hp_date >> 18) - today).to_i
            spade[:img_url] = "images/#{spade[:id].downcase}.png"
        when 18..20
        	spade[:id] = "EMERALT"
            spade[:name] = "Emerald"
            spade[:days_down] = (today - (hp_date >> 18)).to_i
            spade[:days_until] = ((hp_date >> 21) - today).to_i
            spade[:img_url] = "images/#{spade[:id].downcase}.png"
        when 21..23
        	spade[:id] = "SAPPHIRE"
            spade[:name] = "Sapphire"
            spade[:days_down] = (today - (hp_date >> 21)).to_i
            spade[:days_until] = ((hp_date >> 24) - today).to_i
            spade[:img_url] = "images/#{spade[:id].downcase}.png"
        when 24..9999
        	spade[:id] = "DIAMOND"
            spade[:name] = "Diamond"
            spade[:days_down] = (today - (hp_date >> 24)).to_i
            spade[:days_until] = -1
            spade[:img_url] = "images/#{spade[:id].downcase}.png"
        else
            "Error parsing range..."
        end

        return spade
    end

    get '/spade_image/:last_hp_date' do
        
        # Stuff user provided date into a Date object, embrcase the highly likely suck...
        begin
            hp = Date.strptime(params[:last_hp_date], '%Y%m%d')
        rescue  ArgumentError
            "Bad date or date forma, use YYYYMMDD format."
        end

        spade = get_spade_status(hp)
        send_file spade[:img_url]
        

    end

    get '/spade_countdown_chart/:last_hp_date' do 
        # Stuff user provided date into a Date object, embrcase the highly likely suck...
        begin
            hp = Date.strptime(params[:last_hp_date], '%Y%m%d')
        rescue  ArgumentError
            "Bad date or date forma, use YYYYMMDD format."
        end

        spade = get_spade_status(hp)

        g = Gruff::SideStackedBar.new('404x22')
        g.hide_legend = g.hide_title = g.hide_line_markers = true
        g.hide_line_numbers = false
        g.top_margin = g.bottom_margin = g.left_margin = g.right_margin = 0
        g.title_margin = g.legend_margin = 0

        g.data(:days_down, [spade[:days_down]], '#09519e')
        
        if spade[:days_until] > -1
            g.data(:days_until, [spade[:days_until]], '#8b0804')
        end

        ilist = ImageList.new
        ilist.from_blob(g.to_blob)
        txt = Draw.new

        ilist.crop!(Magick::CenterGravity, 400, 18)

        if spade[:days_down] >= 3 || spade[:days_until] == -1
            ilist.annotate(txt, 0,0,4,0, "#{spade[:days_down]}"){
                txt.gravity = Magick::WestGravity
                txt.pointsize = 14
                txt.fill = '#ffffff'
                txt.font_weight = Magick::BoldWeight
            }
        end

        if spade[:days_until] >= 3
            ilist.annotate(txt, 0,0,7,0, "#{spade[:days_until]}"){
                txt.gravity = Magick::EastGravity
                txt.pointsize = 14
                txt.fill = '#ffffff'
                txt.font_weight = Magick::BoldWeight
            }
        end

        content_type 'image/png'
        ilist.to_blob

    end
    not_found do
        status 404
        "404 File Not Found"
    end

end
