Gem::Specification.new do |s|
  s.name = 'keystroker'
  s.version = '0.1.2'
  s.summary = 'Makes it easier to convert keystrokes from 1 format to another. Primary format is KBML.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/keystroker.rb']
  s.add_runtime_dependency('rexle', '~> 1.5', '>=1.5.1')  
  s.signing_key = '../privatekeys/keystroker.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/keystroker'
end
