FROM ruby
WORKDIR /app
COPY ./exams-app .
RUN bundle install
CMD ["ruby", "app.rb"]
EXPOSE 3000
