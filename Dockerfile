FROM ruby
WORKDIR /app
COPY . .
RUN bundle install
CMD [ "ruby", "server.rb" ]
EXPOSE 3000
