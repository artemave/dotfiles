#!/usr/bin/env ruby

require 'ftools'

BACKUP_DIR = '/tmp/myrcs'
pwd = File.dirname( File.expand_path(__FILE__) )

def backup(file)
  File.makedirs BACKUP_DIR

  existing_file = File.expand_path('~/') + '/' + File.basename(file)
  
  if File.exists? existing_file
    if File.symlink? existing_file
      `rm #{existing_file}`
      puts "Removing old link: #{existing_file}"
    else
      `mv #{existing_file} #{BACKUP_DIR}/#{File.basename(existing_file)}`
      puts "Backing up: mv #{existing_file} #{BACKUP_DIR}/#{File.basename(existing_file)}"
    end
  end
end

def link(file)
  `ln -s #{file} ~/`
  puts "ln -s #{file} ~/"
end


puts "Installing dot files..."

Dir.glob("#{pwd}/*", File::FNM_DOTMATCH).each do |f|
  next if f =~ /\.$|\.\.|.git$|.gitignore|.swp$|install.rb/

  backup f

  link f
end

puts "\nDone!"
