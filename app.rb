require 'rubygems'
require 'sinatra'
require 'excon'
require 'json'
CLIENT_ID = ENV['FOUR_SQUARE_CLIENT_ID']
CLIENT_SECRET = ENV['FOUR_SQUARE_CLIENT_SECRET']
GMAPS_KEY = ENV['GOOGLE_MAP_JS_API_KEY']

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

get '/' do
  erb :map
end

get '/render_rain_map' do
  fsqr_qry = "https://api.foursquare.com/v2/venues/search?client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&limit=50&ll=40.706888%2C-74.011650&query=movie+theatre&v=20131014"
  fsqr_cinemas = JSON.parse(Excon.get(fsqr_qry).body)['response']['venues']
  merlin_url = "http://merlin-db.jeffsloyer.io/api/v1/location/"
  merlin_responses = []
  cinemas = []

  fsqr_cinemas.each do |cinema|
    response = JSON.parse(Excon.get(merlin_url + cinema['id']).body)
    unless !!response['error']
      if response['Rain'] < 500
        merlin_responses.push(response)
        cinemas.push(cinema)
      end
    end
  end

  dropoffs = [];
  merlin_responses.each do  |cinema|
    lat = cinema['Latitude'].round(6)
    lng = cinema['Longitude'].round(6)
    times = cinema['Rain']
    times.times do
      dropoffs.push({:lat => lat, :lng => lng})
    end

  end

  erb :render_rain_map, :layout => false, :locals => { :cinemas => cinemas, :dropoffs => dropoffs, :api_key => GMAPS_KEY }
end

get '/render_no_rain_map' do
  fsqr_qry = "https://api.foursquare.com/v2/venues/search?client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&limit=50&ll=40.706888%2C-74.011650&query=movie+theatre&v=20131014"
  fsqr_cinemas = JSON.parse(Excon.get(fsqr_qry).body)['response']['venues']
  merlin_url = "http://merlin-db.jeffsloyer.io/api/v1/location/"
  merlin_responses = []
  cinemas = []

  fsqr_cinemas.each do |cinema|
    response = JSON.parse(Excon.get(merlin_url + cinema['id']).body)
    unless !!response['error']
      if response['Sunny'] < 500
        merlin_responses.push(response)
        cinemas.push(cinema)
      end
    end

  end


  dropoffs = [];
  merlin_responses.each do  |cinema|
    lat = cinema['Latitude'].round(6)
    lng = cinema['Longitude'].round(6)
    times = cinema['Sunny']
    # uncomment this to cheat the data for demonstration purposes
    #if (1 + rand(3)) == 1
    #  times += (1 + rand(1000..2000))
    #end
    times.times do
      dropoffs.push({:lat => lat, :lng => lng})
    end
  end

  erb :render_no_rain_map, :layout => false, :locals => { :cinemas => cinemas, :dropoffs => dropoffs, :api_key => GMAPS_KEY }
end
