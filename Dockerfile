FROM ruby:2.3
ENV RACK_ENV production
RUN mkdir /app
ADD * /app/
WORKDIR /app
RUN bundle install --without development test
EXPOSE 80
CMD bundle exec thin -p 80 start
