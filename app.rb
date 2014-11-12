require 'sinatra'
require 'oauth'

def oauth_consumer
  key = ENV['CONSUMER_KEY']
  secret = ENV['CONSUMER_SECRET']
  OAuth::Consumer.new(key, secret, :site => 'https://api.twitter.com')
end

get '/' do
  erb :index
end

def base_url
  default_port = (request.scheme == "http") ? 80 : 443
  port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
  "#{request.scheme}://#{request.host}#{port}"
end

get '/request_token' do
  callback_url = "#{base_url}/access_token"
  request_token = oauth_consumer.get_request_token(:oauth_callback => callback_url)
  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret
  redirect request_token.authorize_url
end

get '/access_token' do
  request_token = OAuth::RequestToken.new(
      oauth_consumer, session[:request_token], session[:request_token_secret])

  begin
    @access_token = request_token.get_access_token(
      {},
      :oauth_token => params[:oauth_token],
      :oauth_verifier => params[:oauth_verifier])
  rescue OAuth::Unauthorized => @exception
    return erb :authorize_fail
  end

  session[:access_token] = @access_token.token
  session[:access_token_secret] = @access_token.secret
  session[:user_id] = @access_token.params['user_id']
  session[:screen_name] = @access_token.params['screen_name']

  erb :authorize_success
end
