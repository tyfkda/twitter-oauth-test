require 'sinatra'

get '/' do
  @text = 'hi'
  erb :index
end
