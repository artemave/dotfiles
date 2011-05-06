#!/usr/bin/env ruby

require 'fileutils'
require 'tmpdir'

BACKUP_DIR = File.join Dir.tmpdir, Time.now.to_i.to_s, 'myrcs'

def backup(file)
  FileUtils.mkdir_p BACKUP_DIR

  basename = File.basename file
  existing_file = File.join Dir.home, basename
  backup_copy = File.join BACKUP_DIR, basename
  
  if File.exists? existing_file
    if File.symlink? existing_file
      puts "Removing old link: #{existing_file}"
      FileUtils.rm existing_file
    else
      puts "Backing up: mv #{existing_file} #{backup_copy}"
      FileUtils.mv existing_file, backup_copy
    end
  end
end

def link_to_home(file)
  puts "ln -s #{file} ~/"
  FileUtils.ln_s file, Dir.home
end

def snippify
  snipmate_path = File.join(Dir.home, '.vim', 'bundle', 'snipmate')
  snipmate_snippets_path = File.join(Dir.home, '.vim', 'bundle', 'snipmate-snippets')
  if Dir.exists?(snipmate_path) and Dir.exists?(snipmate_snippets_path)
    current_dir = Dir.pwd
    puts 'Installing more cool snippets...'
    begin
      Dir.chdir snipmate_snippets_path
      `rake deploy_local`
      puts 'Done with snippets.'
    ensure
      Dir.chdir current_dir
    end
  else
    puts 'No cool vim snippets. Skipping.'
  end
end

puts "Installing dot files..."

Dir.glob("#{Dir.pwd}/*", File::FNM_DOTMATCH).each do |f|
  next if f =~ /\.$|\.\.|.git$|.swp$|install.rb/

  backup f
  link_to_home f
end

snippify()

puts "\nDone!"
