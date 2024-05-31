FROM ruby:3.1.4

RUN apt-get update -qq && \
  apt-get install -y build-essential libpq-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY app/Gemfile* ./
RUN gem install bundler && bundle install
COPY app/ .
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
