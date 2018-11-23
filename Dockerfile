FROM ruby:latest
COPY clonk-1.0.0alpha4.gem .
RUN gem install clonk-1.0.0alpha4.gem --development
CMD ["ruby", "seed_script.rb"]
