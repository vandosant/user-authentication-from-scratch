require 'sinatra/base'
require 'bcrypt'

class Application < Sinatra::Application

  def initialize(app=nil)
    super(app)

    # initialize any other instance variables for you
    # application below this comment. One example would be repositories
    # to store things in a database.

  end

  enable :sessions

  def logged_in?
    unless session[:id] == nil
      return true
    end
  end


  get '/' do
    if logged_in?
      user_data = DB[:users].where(:id => session[:id]).to_a.first
      erb :index, locals: {:user_data => user_data, :logged_in => true}
    else
      erb :index, locals: {:logged_in => false}
    end
  end

  get '/register' do
    erb :register
  end

  post '/' do
    new_password = BCrypt::Password.create(params[:password])
    session[:id] = DB[:users].insert(:email => params[:email_address], :password => new_password)
    redirect '/'
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/login' do
    erb :login, locals: {:error => false}
  end

  post '/login' do
    this_email_data = DB[:users].where(:email => params[:email_address]).to_a.first
    password_matching_email = BCrypt::Password.new(this_email_data[:password])

    if password_matching_email == params[:password]
      session[:id] = this_email_data[:id]
      redirect '/'
    else
      erb :login, locals: {:error => true}
    end
  end

end