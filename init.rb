# -*- coding: utf-8 -*-
# Author: seniorihor (c) 2012

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'haml'
# DataMapper
require 'dm-core'
# DataMapper plugin for magical timestamps
require 'dm-timestamps'
# DataMapper plugin providing extra data types
require 'dm-validations'
# DataMapper plugin for writing and speccing migrations
require 'dm-migrations'
# DataMapper plugin providing extra data types
require 'dm-types'
# DataMapper plugin providing support for aggregates, functions on collections and datasets
#require 'dm-aggregates'
# Adds support for transaction to datamapper
#require 'dm-transactions'
# DataMapper plugin for serializing Resources and Collections
#require 'dm-serializer'


# Database
DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/db/forum.db")


class User

  include DataMapper::Resource

  def initialize(params)
    self.username = params[:username]
    self.email    = params[:email]
    self.password = params[:password]
    self.save
  end


  property :id,       Serial
  property :username, String, required: true, unique: true, length: 2..20
  property :email,    String, required: true, unique: true, format: :email_address
  property :password, String, required: true, length: 6..20

  has n,   :tasks

  def self.login(username, password)
    user = self.get(1) # Fix it
    false if user.nil?
    password == user.password ? true : false
  end
end


class Task

  include DataMapper::Resource

  def initialize(params)
    self.title    = params[:title]
    self.body     = params[:body]
    self.priority = params[:priority]
    self.user_id  = params[:user_id]
    self.save
  end

  property   :id,         Serial
  property   :title,      String,  required: true
  property   :body,       Text,    required: true
  property   :priority,   Enum[1, 2, 3, 4, 5]
  property   :created_at, DateTime
  property   :read,       Boolean, default: false

  belongs_to :user

  def self.show(id)
    #code...
  end

  def self.delete(id)
    #code...
  end
end

DataMapper.auto_upgrade!


# Set unicode for outgoing actions
before do
  headers 'Content-Type' => 'text/html; charset=utf-8'
end

# Users
get '/' do
  @title = 'Home page'
  haml :index
end

get '/register' do
  @title = 'Register'
  haml :register
end

get '/do_register' do
  if User.new(params) # fix it: if user not saved — must redirect to /register
    redirect '/login'
  else
    #'user not saved!'
    redirect '/register'
  end
end

get '/login' do
  @title = 'Login'
  haml :login
end

get '/do_login' do
  username = params[:username]
  password = params[:password]
  if User.login(username, password)
    redirect '/tasks'
  else
    #'user not login!'
    redirect '/login'
  end
end

# Tasks
get '/tasks' do
  @title = 'Tasks'
  haml :'tasks/index'
  #@tasks = Task.all ? Task.all : nil
end

get '/tasks/new' do
  @title = 'Tasks | New'
  haml :'tasks/new'
end

get '/tasks/do_new' do
  if Task.new(params)
    redirect '/tasks'
  else
    'task not saved!'
  end
end

get '/tasks/show/:id' do
  Task.show(params[:id])
end

get '/tasks/delete/:id' do
  Task.delete(params[:id])
end
