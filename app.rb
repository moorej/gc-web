require 'sinatra'
require './chart'

include Magick


class App < Sinatra::Application
    get '/spade_image/:date' do
        date = query_date_to_date(params[:date])
        spade = Spade.new(date)
        send_file spade.img_url
    end

    get '/spade_countdown_chart/:date' do 
        date = query_date_to_date(params[:date])
        s = Spade.new(date)
        
        t = s.next_name ? "#{s.days_until} Days Until #{s.next_name}" : "#{s.days_down} Days With #{s.name}"

        c = Chart.new(s.days_down, s.days_until, t)

        content_type 'image/png'
        c.to_blob
    end

    not_found do
        status 404
        "404 File Not Found"
    end

    def query_date_to_date(date)
        # Stuff user provided date into a Date object, embrcase the highly likely suck...
        begin
            Date.strptime(date, '%Y%m%d')
        rescue  ArgumentError
            "Bad date or date format, use YYYYMMDD format."
        end
    end

end
