# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'clonk'
  s.version = '2.2.7'
  s.authors = ['Simon Fish']
  s.date = '2019-02-19'
  s.summary = 'Keycloak/RHSSO admin API client'
  s.files = Dir['lib/**/**.rb']
  s.add_runtime_dependency 'faraday'
  s.add_runtime_dependency 'faraday_middleware'
  s.add_development_dependency 'byebug'
  s.metadata['yard.run'] = 'yri'
end
