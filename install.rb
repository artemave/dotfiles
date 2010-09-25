#!/usr/bin/env ruby

Dir["*", File::FNM_DOTMATCH].each do |f|
  puts f
end
