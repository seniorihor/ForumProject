# -*- coding: utf-8 -*-

require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'data_mapper'


# Database
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/forum.db")


class User
  include DataMapper::Resource

  property :id,       Serial
  property :username, String, required: true, unique: true, length: 2..20
  property :email,    String, required: true, unique: true, format: :email_address
  property :password, String, required: true, length: 6..20

  has n,   :tasks

  def self.register(username, email, password)
    user = User.new
    user.username = username
    user.email    = email
    user.password = password
    user.save
  end

  def self.login(username, password)
    user = User.get(1)
    false if user.nil?
    password == user.password ? true : false
  end
end


class Task

  include DataMapper::Resource

  property   :id,         Serial
  property   :title,      String,  required: true
  property   :body,       Text,    required: true
  property   :priority,   Enum[1, 2, 3, 4, 5]
  property   :created_at, DateTime
  property   :read,       Boolean, default: false

  belongs_to :user

  def self.show

  end

  def self.new

  end

  def self.delete

  end
end

DataMapper.auto_upgrade!


# Actions
get '/' do
  @title = 'Home page'
  haml :index
end

get '/login' do
  @title = 'Login'
  haml :login
end

get '/do_login' do
  username = params[:username]
  password = params[:password]
  if User.login(username, password)
    redirect '/congratulation'
  else
    'user not login!'
  end
end

get '/register' do
  @title = 'Register'
  haml :register
end

get '/do_register' do
  username = params[:username]
  email    = params[:email]
  password = params[:password]
  if User.register(username, email, password)
    redirect '/login'
  else
    'user not saved!'
  end
end

get '/tasks' do
  @title = 'Tasks'
  haml :tasks
end
