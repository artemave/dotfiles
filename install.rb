#!/usr/bin/env ruby

require 'fileutils'
require 'tmpdir'

BACKUP_DIR = File.join Dir.tmpdir, Time.now.to_i.to_s, 'myrcs'
HOME_DIR = Dir.respond_to?(:home) ? Dir.home : ENV['HOME']
BUNDLE_PATH = File.join(HOME_DIR, '.vim', 'bundle')

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

# this is now obsolete. It used to be useful when snipmate.vim itself contained snippets
def snippify
  snipmate_path = File.join(BUNDLE_PATH, 'snipmate')
  more_snippets_path = File.join(BUNDLE_PATH, 'snipmate-snippets', 'snippets')

  if File.exists?(snipmate_path) and File.exists?(more_snippets_path)
    puts 'Installing more cool snippets...'
    FileUtils.rm_rf "#{snipmate_path}/snippets", :verbose => true
    FileUtils.cp "#{more_snippets_path}/support_functions.vim", "#{snipmate_path}/plugin", :verbose => true
    #FileUtils.ln_s more_snippets_path, snippets_path, :verbose => true
    puts 'Done with snippets.'
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

#snippify()

puts "\nDone!"
