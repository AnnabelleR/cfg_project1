require 'sinatra'
require 'mongoid'
require 'json'
require 'pony'

## Mongoid setup
## =============

Mongoid.load!("mongoid.yml")
    
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