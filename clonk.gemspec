Gem::Specification.new do |s|
  s.name = %q{clonk}
  s.version = "1.0.0alpha"
  s.authors = ["Simon Fish"]
  s.date = %q{2018-11-19}
  s.summary = %q{Keycloak/RHSSO admin API client}
  s.files = [
    "Gemfile",
    "lib/clonk.rb"
  ]
  s.require_paths = ["lib"]
  s.add_runtime_dependency 'faraday'
  s.add_runtime_dependency 'faraday_middleware'
end
