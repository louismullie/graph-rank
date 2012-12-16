$:.push File.expand_path('../lib', __FILE__)

require 'graph-rank'

Gem::Specification.new do |s|
  
  s.name        = 'graph-rank'
  s.version     = GraphRank::VERSION
  s.authors     = ['Louis Mullie']
  s.email       = ['louis.mullie@gmail.com']
  s.homepage    = 'https://github.com/louismullie/graphrank'
  s.summary     = %q{ GraphRank: bringing TextRank and PageRank to Ruby. }
  s.description = %q{ GraphRank is an impementation of TextRank and PageRank in Ruby. }
  
  # Add all files.
  s.files = Dir['lib/**/*'] + ['README.md', 'LICENSE']
  
end