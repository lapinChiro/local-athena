# config/puma.rb
workers 3
preload_app!

port ENV.fetch("PORT") { 3000 }
