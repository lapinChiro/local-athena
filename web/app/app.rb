# frozen_string_literal: true

require 'sinatra'

enable :method_override

get '/' do
  "Hello World!"
end
