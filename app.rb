require 'sinatra'
require 'mongoid'
require 'json'
require 'pony'

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


get '/:name/:name2' do
    @name = params[:name].capitalize
    @name2 = params[:name2].capitalize
    erb :index
end

get '/party/:name/:name2' do
    @name = params[:name].capitalize
    @name2 = params[:name2].capitalize
    erb :index2
end

post '/' do
    username = params[:name]
    useremail = params[:email]
    @user = User.new(:name => username, :email => useremail)
    @user.save
    Pony.mail(:to => useremail, :subject => "Happy Birthday!! Someone sent you a card!", :body => erb(:index))
    erb :thanks

end