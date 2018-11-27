lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = %q{clonk}
  s.version = "1.0.0"
  s.authors = ["Simon Fish"]
  s.date = %q{2018-11-27}
  s.summary = %q{Keycloak/RHSSO admin API client}
  s.files = Dir['lib/**/**.rb']
  s.add_runtime_dependency 'faraday'
  s.add_runtime_dependency 'faraday_middleware'
  s.add_development_dependency 'byebug'
  s.metadata["yard.run"] = "yri"
end
