require 'sinatra'
require 'rack/handler/puma'
require 'csv'
require 'pg'

conn = PG::Connection.new('localhost', 5432, nil, nil, 'rebase-labs', 'postgres', 'password')

get '/tests' do
  result = conn.exec('SELECT * FROM medicalexams LIMIT 5')
  arr = []
  result.each do |tuple|
    arr << tuple.to_h
  end
  arr.to_json
end

get '/' do
  erb :index
end

Rack::Handler::Puma.run(
  Sinatra::Application,
  Port: 3000,
  Host: '0.0.0.0'
)
