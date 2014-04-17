require 'sinatra/base'
require 'bcrypt'

class Application < Sinatra::Application

  def initialize(app=nil)
    super(app)
  end

  enable :sessions

  def logged_in?
    unless session[:id] == nil
      return true
    end
  end

  def admin?
    user_data = DB[:users].where(:id => session[:id]).to_a.first
    user_data[:admin]
  end

  get '/' do
    if !logged_in?
      erb :index, locals: {:logged_in => false, :admin => false}
    elsif logged_in? && admin?
      user_data = DB[:users].where(:id => session[:id]).to_a.first
      erb :index, locals: {:user_data => user_data, :logged_in => true, :admin => true}
    elsif logged_in?
      user_data = DB[:users].where(:id => session[:id]).to_a.first
      erb :index, locals: {:user_data => user_data, :logged_in => true, :admin => false}
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

    if this_email_data == nil
      erb :login, locals: {:error => true}
    else
      password_matching_email = BCrypt::Password.new(this_email_data[:password])
      if password_matching_email == params[:password]
        session[:id] = this_email_data[:id]
        redirect '/'
      else
        erb :login, locals: {:error => true}
      end
    end
  end

  get '/users' do
    user_data = DB[:users].where(:id => session[:id]).to_a.first
    redirect '/' unless user_data[:admin]
    erb :users, locals: {:users => DB[:users].to_a, :user_data => user_data}
  end
end