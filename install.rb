#!/usr/bin/env ruby

require 'ftools'

BACKUP_DIR = '/tmp/myrcs'

def backup(file)
  File.makedirs BACKUP_DIR

  current_file = File.expand_path('~/') + '/' + File.basename(file)
  
  if File.exists? current_file
    if File.symlink? current_file
      puts "Removing old link: #{current_file}"
      `rm #{current_file}`
    else
      puts "Backing up: mv #{current_file} #{BACKUP_DIR}/#{File.basename(current_file)}"
      `mv #{current_file} #{BACKUP_DIR}/#{File.basename(current_file)}`
    end
  end
end

def link_to_home(file)
  puts "ln -s #{file} ~/"
  `ln -s #{file} ~/`
end


puts "Installing dot files..."

pwd = File.dirname( File.expand_path(__FILE__) )

Dir.glob("#{pwd}/*", File::FNM_DOTMATCH).each do |f|
  next if f =~ /\.$|\.\.|.git$|.swp$|install.rb/

  backup f
  link_to_home f
end

puts "\nDone!"
