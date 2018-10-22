require 'sinatra'
require 'date'
require './chart'

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

    get '/garden_goal_chart/:start_date/:end_date' do
        start_date = query_date_to_date(params[:start_date])
        end_date = query_date_to_date(params[:end_date])
        today = Date.today

        days_down = (today - start_date).to_i
        days_left = today <= end_date ? (end_date - today).to_i : -1
        t = days_left > 0 ?  "#{days_left} Days Until My Garden Goal" : "#{days_down} Days In The Garden"

        c = Chart.new(days_down, days_left, t)

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
