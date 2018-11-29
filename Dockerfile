FROM ruby:latest
COPY clonk-1.0.0.gem .
RUN gem install clonk-1.0.0.gem --development
RUN gem install rspec-core rspec-mocks rspec-expectations webmock faker simplecov
CMD ["irb"]
