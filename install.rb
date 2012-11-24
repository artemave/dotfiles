#!/usr/bin/env ruby

require 'fileutils'
require 'tmpdir'

BACKUP_DIR  = File.join Dir.tmpdir, Time.now.to_i.to_s, 'myrcs'
HOME_DIR    = Dir.respond_to?(:home) ? Dir.home : ENV['HOME']
VIM_PATH    = File.join HOME_DIR, '.vim'
BUNDLE_PATH = File.join VIM_PATH, 'bundle'

def backup(file)
  basename = File.basename file
  existing_file = File.join HOME_DIR, basename
  backup_copy = File.join BACKUP_DIR, "#{Time.now}_#{basename}"

  if File.exists? existing_file
    if File.symlink? existing_file
      FileUtils.rm existing_file, :verbose => true
    else
      FileUtils.mv existing_file, backup_copy, :verbose => true
    end
  end
end

def link_to_home(file)
  FileUtils.ln_s file, HOME_DIR, :verbose => true
end

def snippify
  if File.exists?(bundled_snippets_path = File.join(BUNDLE_PATH, 'snipmate', 'snippets'))
    FileUtils.rm_rf bundled_snippets_path, :verbose => true
  end

  more_snippets_path = File.join BUNDLE_PATH, 'snipmate-snippets'
  dest_snippets_path = File.join VIM_PATH, 'snippets'

  if File.exists?(more_snippets_path)
    puts 'Installing snippets...'
    if File.exists?(File.join more_snippets_path, 'snippets')
      puts 'Snippets are already where they should be. Nothing to do.'
    else
      FileUtils.rm_rf dest_snippets_path, :verbose => true rescue nil
      FileUtils.ln_s more_snippets_path, dest_snippets_path, :verbose => true
      puts 'Done.'
    end
  else
    puts 'No cool vim snippets. Skipping.'
  end
end

def git_config
  `git config --global core.excludesfile ~/.gitignore`
  `git config --global user.name artemave`
  `git config --global user.email artemave@gmail.com`
end

puts 'Updating git submodules...'
puts `git submodule update --init`
puts 'Done!'

puts "Installing dot files..."

FileUtils.mkdir_p BACKUP_DIR, :verbose => true
File.open 'path_to_backup.txt', 'w' do |file|
  file.write BACKUP_DIR
end

Dir.glob("#{Dir.pwd}/*", File::FNM_DOTMATCH).each do |f|
  next if f =~ /\.$|\.\.|.git$|.swp$|.gitmodules|install.rb/

  backup f
  link_to_home f
end

git_config()

vundle_install_path = File.join BUNDLE_PATH, 'vundle'
unless File.exists?(vundle_install_path)
  `git clone http://github.com/gmarik/vundle.git #{vundle_install_path}`
end

snippify

puts "\nDone!"
