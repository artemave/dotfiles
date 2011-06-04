#!/usr/bin/env ruby

require 'fileutils'
require 'tmpdir'

BACKUP_DIR = File.join Dir.tmpdir, Time.now.to_i.to_s, 'myrcs'
HOME_DIR = Dir.respond_to?(:home) ? Dir.home : ENV['HOME']

def backup(file)
  FileUtils.mkdir_p BACKUP_DIR

  basename = File.basename file
  existing_file = File.join HOME_DIR, basename
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
  FileUtils.ln_s file, HOME_DIR
end

def snippify
  snipmate_path = File.join(HOME_DIR, '.vim', 'bundle', 'snipmate')
  more_snippets_path = File.join(HOME_DIR, '.vim', 'bundle', 'snipmate-snippets', 'snippets')
  if File.exists?(snipmate_path) and File.exists?(more_snippets_path)
    puts 'Installing more cool snippets...'
    FileUtils.rm_rf "#{snipmate_path}/snippets"
    FileUtils.cp "#{more_snippets_path}/support_functions.vim", "#{snipmate_path}/plugin"
    #FileUtils.ln_s more_snippets_path, snippets_path
    puts 'Done with snippets.'
  else
    puts 'No cool vim snippets. Skipping.'
  end
end

`git submodule update --init`

puts "Installing dot files..."

Dir.glob("#{Dir.pwd}/*", File::FNM_DOTMATCH).each do |f|
  next if f =~ /\.$|\.\.|.git$|.swp$|.gitmodules|install.rb/

  backup f
  link_to_home f
end

snippify()

puts "\nDone!"
