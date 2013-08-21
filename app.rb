require 'sinatra'
require 'mongoid'
require 'json'
require 'pony'
require 'uri'

## MongoHQ with Heroku
## =============
if ENV["MONGOHQ_URL"] 
  mongo_uri = URI.parse(ENV["MONGOHQ_URL"]) 
  ENV['MONGOID_HOST'] = mongo_uri.host 
  ENV['MONGOID_PORT'] = mongo_uri.port.to_s 
  ENV["MONGOID_USERNAME"] = mongo_uri.user 
  ENV['MONGOID_PASSWORD'] = mongo_uri.password 
  ENV['MONGOID_DATABASE'] = mongo_uri.path.gsub(”/”, ””) 
end

## Mongoid setup
## =============

Mongoid.load!("mongoid.yml", :development)
    
class User
    include Mongoid::Document

    field :name
    field :email
end

## Email setup
## ===========

Pony.options = { 
  :via => 'smtp',
  :via_options => {
      :address              => 'smtp.gmail.com',
      :port                 => '587',
      :enable_starttls_auto => true,
      :user_name            => ENV['USER_NAME'],
      :password             => ENV['PASSWORD'],
      :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
    }
  }


## Sinatra app
## ===========
get '/' do
    erb :welcome
end

get '/:name1/:name2' do
    @name1 = params[:name1].capitalize
    @name2 = params[:name2].capitalize
    erb :index
end

get '/party/:name1/:name2' do
    @name1 = params[:name1].capitalize
    @name2 = params[:name2].capitalize
    erb :index2
end

post '/:name1/:name2' do
    name = params[:username]
    email = params[:useremail]
    @user = User.new(:name => name, :email => email)
    @user.save
    Pony.mail(:to => email, :subject => "Happy Birthday!!", :body => erb(:email, :layout => false))
    erb :thanks
end

post '/party/:name1/:name2' do
    name = params[:username]
    email = params[:useremail]
    @user = User.new(:name => name, :email => email)
    @user.save
    Pony.mail(:to => email, :subject => "Happy Birthday!!", :body => erb(:email, :layout => false))
    erb :thanks
end



get '/list' do

    @users = User.all
    erb :list

end