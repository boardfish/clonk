Gem::Specification.new do |s|
  s.name = %q{clonk}
  s.version = "0.0.1"
  s.authors = ["Simon Fish"]
  s.date = %q{2018-11-17}
  s.summary = %q{Keycloak/RHSSO admin API client}
  s.files = [
    "Gemfile",
    "lib/clonk.rb"
  ]
  s.require_paths = ["lib"]
  s.add_runtime_dependency 'faraday'
  s.add_runtime_dependency 'faraday_middleware'
  s.add_development_dependency 'byebug'
end
