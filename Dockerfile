FROM ruby:latest
COPY clonk-2.2.9.gem .
RUN gem install clonk-2.2.9.gem --development
RUN gem install rspec-core rspec-mocks rspec-expectations webmock faker simplecov
CMD ["irb"]
