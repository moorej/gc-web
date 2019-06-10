require 'sinatra'
require 'date'
require './chart'
require 'digest'

class App < Sinatra::Application
    set :static_cache_control, [:public, :max_age => 3600]

    before do
        cache_control :public, :must_revalidate, :max_age => 3600
        # expires 3600, :public, :must_revalidate
    end

    get '/' do
        send_file File.join(settings.public_folder, 'readme.html')
    end

    get '/spade_image/:date' do
        date = query_date_to_date(params[:date])
        halt 400, "400 Date must be in the past" unless date <= Date.today
        spade = Spade.new(date)

        last_modified(spade.start_date)
        etag Digest::MD5.hexdigest spade.id

        send_file spade.img_url
    end

    get '/spade_countdown_chart/:date' do 
        etag Digest::MD5.hexdigest Date.today.to_s

        date = query_date_to_date(params[:date])
        halt 400, "400 Date must be in the past" unless date <= Date.today
        s = Spade.new(date)        
        t = s.next_name ? "#{s.days_until} Days Until #{s.next_name}" : "#{s.days_down} Days With #{s.name}"
        c = Chart.new(s.days_down, s.days_until, t)

        content_type 'image/png'
        c.to_blob
    end

    get '/garden_goal_chart/:start_date/:end_date' do
        today = Date.today
        etag Digest::MD5.hexdigest today.to_s

        start_date = query_date_to_date(params[:start_date])
        halt 400, "400 Start date must be in the past" unless start_date <= today
        end_date = query_date_to_date(params[:end_date])
        halt 400, "400 Start date must be before end date" unless start_date <= end_date

        days_down = (today - start_date).to_i
        days_left = today <= end_date ? (end_date - today).to_i : -1
        t = days_left > 0 ?  "#{days_left} Days Until My Garden Goal" : "#{days_down} Days In The Garden"

        c = Chart.new(days_down, days_left, t)

        content_type 'image/png'
        c.to_blob
    end

    get '/custom_goal_chart/:start_date/:end_date/:countdown_text/:success_text' do
        today = Date.today
        etag Digest::MD5.hexdigest today.to_s

        start_date = query_date_to_date(params[:start_date])
        halt 400, "400 Start date must be in the past" unless start_date <= today
        end_date = query_date_to_date(params[:end_date])
        halt 400, "400 Start date must be before end date" unless start_date <= end_date

        days_down = (today - start_date).to_i
        days_left = today <= end_date ? (end_date - today).to_i : -1
        t = days_left > 0 ?  "#{days_left} #{CGI::unescape(params[:countdown_text])}" : "#{days_down} #{CGI::unescape(params[:success_text])}"

        c = Chart.new(days_down, days_left, t)

        content_type 'image/png'
        c.to_blob
    end

    not_found do
        status 404
        "404 File Not Found"
    end

    def query_date_to_date(date)
        # Stuff user provided date into a Date object, embrace the highly likely suck...
        begin
            Date.strptime(date, '%Y%m%d')
        rescue  ArgumentError
            halt 400, "400 Bad date or date format, use YYYYMMDD format."
        end
    end

end
