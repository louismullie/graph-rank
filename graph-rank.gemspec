$:.push File.expand_path('../lib', __FILE__) #What does this do? expand ruby's path ($) with a lib dir in current file's dir so stuff in it can be required : http://stackoverflow.com/questions/10372880/what-does-push-do-in-ruby

require 'graph-rank'

Gem::Specification.new do |s|
  
  s.name        = 'graph-rank'
  s.version     = GraphRank::VERSION
  s.authors     = ['Soheil Danesh']
  s.email       = ['soheildb@gmail.com']
  s.homepage    = 'https://github.com/soheildanesh/graph-rank'
  s.summary     = %q{ GraphRank: bringing TextRank and PageRank to Ruby. }
  s.description = %q{ GraphRank is an impementation of TextRank and PageRank in Ruby. }
  
  # Add all files.
  s.files = Dir['lib/**/*'] + ['README.md', 'LICENSE']
  
end