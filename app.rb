require 'rubygems'
require 'sinatra'
require 'date'
require 'gruff'
require 'rmagick'
require 'open-uri'
include Magick


class App < Sinatra::Application
    @@spades = [
        { :id => 'SEEDLING', :name => 'Seedling', :min_mo => 0, :dur => 1 },
        { :id => 'BRONZE', :name => 'Bronze Spade', :min_mo => 1, :dur => 2 },
        { :id => 'SILVER', :name => 'Silver Spade', :min_mo => 3, :dur => 3 },
        { :id => 'GOLD', :name => 'Gold Spade', :min_mo => 6, :dur => 3 },
        { :id => 'PALLADIUM', :name => 'Palladium Spade', :min_mo => 9, :dur => 3 },
        { :id => 'PLATINUM', :name => 'Platinum Spade', :min_mo => 12, :dur => 3 },
        { :id => 'RUBY', :name => 'Ruby Spade', :min_mo => 15, :dur => 3 },
        { :id => 'EMERALD', :name => 'Emerald Spade', :min_mo => 18, :dur => 3 },
        { :id => 'SAPPHIRE', :name => 'Sapphire Spade', :min_mo => 21, :dur => 3 },
        { :id => 'DIAMOND', :name => 'Diamond', :min_mo => 24, :dur => 9999 }
    ]

    def get_spade_status(hp_date)
        # returns has of status
        
        spade = {}
      
        today = Date.today

        # Grab the number of months the users been in the garden
        hp_age_months = (today.year * 12 + today.month) - (hp_date.year * 12 + hp_date.month)
        if (hp_date.day > today.day)
            hp_age_months -= 1
        end

        @@spades.each do |s|
            if (s[:min_mo]..(s[:min_mo] + s[:dur])) === hp_age_months
                spade[:id] = s[:id]
                spade[:name] = s[:id]
                spade[:days_down] = (today - (hp_date >> s[:min_mo])).to_i
                
                if s[:dur] != 9999
                    spade[:days_until] = ((hp_date >> (s[:min_mo] + s[:dur])) - today).to_i
                else
                    spade[:days_until] = -1
                end

                spade[:img_url] = "images/#{spade[:id].downcase}.png"

            end
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

        g = Gruff::SideStackedBar.new('401x21')
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

        if spade[:days_down] >= 3 || spade[:days_until] == -1
            if spade[:days_down] >= 14
                left_text = "#{spade[:days_down]} down"
            else
                left_text = "#{spade[:days_down]}"
            end

            ilist.annotate(txt, 0,0,3,4, left_text){
                txt.gravity = Magick::WestGravity
                txt.pointsize = 14
                txt.fill = '#ffffff'
                txt.font_weight = Magick::BoldWeight
            }
        end

        if spade[:days_until] >= 3
            if spade[:days_until] >= 13
                right_text = "#{spade[:days_until]} to go"
            else
                right_text = "#{spade[:days_until]}"
            end
            
            ilist.annotate(txt, 0,0,2,4, right_text){
                txt.gravity = Magick::EastGravity
                txt.pointsize = 14
                txt.fill = '#ffffff'
                txt.font_weight = Magick::BoldWeight
            }
        end

        ilist.annotate(txt, 0,0,0,3, "Days Until Next Spade"){
            txt.gravity = Magick::CenterGravity
            txt.pointsize = 12
            txt.fill = '#ffffff'
            #txt.font_weight = Magick::BoldWeight
        }

        ilist.crop!(0, 4, 400, 18)

        content_type 'image/png'
        ilist.to_blob

    end

    not_found do
        status 404
        "404 File Not Found"
    end

end
