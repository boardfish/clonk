FROM ruby:latest
COPY clonk-2.2.1.gem .
RUN gem install clonk-2.2.1.gem --development
RUN gem install rspec-core rspec-mocks rspec-expectations webmock faker simplecov
CMD ["irb"]
