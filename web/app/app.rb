# frozen_string_literal: true

require 'sinatra'
require './lib/trino/client'

enable :method_override

get '/' do
  "Hello World!"
end
