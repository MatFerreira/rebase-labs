FROM ruby
WORKDIR /app
COPY ./exams-app .
RUN bundle install
CMD [ "ruby", "src/server.rb"]
EXPOSE 3000
