FROM ruby:latest
COPY clonk-1.0.0alpha6.gem .
RUN gem install clonk-1.0.0alpha6.gem
CMD ["ruby", "seed_script.rb"]
