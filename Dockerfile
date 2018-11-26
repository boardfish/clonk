FROM ruby:latest
COPY clonk-1.0.0alpha6.gem .
RUN gem install clonk-1.0.0alpha6.gem rspec-core rspec-mocks rspec-expectations webmock faker
CMD ["irb"]
