#!/usr/bin/env ruby
#
require "rubygems"
require "thor"
require 'fileutils'

class DotsInstaller < Thor
  SOURCE_ROOT = File.expand_path File.dirname __FILE__
  BACKUP_DIR  = SOURCE_ROOT + '/backup'
  HOME_DIR    = Dir.respond_to?(:home) ? Dir.home : ENV['HOME']
  VIM_PATH    = File.join HOME_DIR, '.vim'
  BUNDLE_PATH = File.join VIM_PATH, 'bundle'

  default_task :install

  desc 'install', "installs dot files into your home dir"
  def install
    inflate_submodules
    backup basenames
    deploy_dot_files basenames
    vundlize
    snippify
  end

  desc 'install_vim', 'installs only Vim bits and bobs'
  def install_vim
    inflate_submodules
    backup vim_basenames
    deploy_dot_files vim_basenames
    vundlize
    snippify
  end

  desc 'git_config USERNAME EMAIL', 'sets global git user settings'
  def git_config(username, email)
    `git config --global core.excludesfile ~/.gitignore`
    `git config --global user.name #{username}`
    `git config --global user.email #{email}`
  end

  no_tasks do
    def backup basenames
      FileUtils.mkdir_p BACKUP_DIR unless File.exists? BACKUP_DIR

      basenames.each do |basename|
        existing_file = File.join HOME_DIR, basename
        backup_copy = File.join BACKUP_DIR, "#{Time.now.to_i}_#{basename}"

        if File.symlink? existing_file
          FileUtils.rm existing_file, :verbose => true
        elsif File.exists? existing_file
          FileUtils.mv existing_file, backup_copy, :verbose => true
        end
      end
    end

    def deploy_dot_files basenames
      home_bin = File.join HOME_DIR, 'bin'
      FileUtils.mkdir_p home_bin unless File.exists? home_bin

      basenames.each do |basename|
        prefix = File.dirname basename
        FileUtils.ln_s (File.join SOURCE_ROOT, basename), File.join(HOME_DIR, prefix), :verbose => true
      end
    end

    def vundlize
      vundle_install_path = File.join BUNDLE_PATH, 'vundle'
      unless File.exists?(vundle_install_path)
        `git clone http://github.com/gmarik/vundle.git #{vundle_install_path}`
      end

      bundle_file = File.join HOME_DIR, '.bundles.vim'
      system "vim --noplugin -u #{bundle_file} +BundleInstall +qa"
    end

    def snippify
      if File.exists?(bundled_snippets_path = File.join(BUNDLE_PATH, 'snipmate', 'snippets'))
        FileUtils.rm_rf bundled_snippets_path, :verbose => true
      end

      more_snippets_path = File.join BUNDLE_PATH, 'snipmate-snippets'
      dest_snippets_path = File.join VIM_PATH, 'snippets'

      if File.exists?(more_snippets_path)
        if File.exists?(File.join more_snippets_path, 'snippets')
          puts 'Snippets are already where they should be. Nothing to do.'
        else
          puts 'Installing snippets...'
          FileUtils.rm_rf dest_snippets_path, :verbose => true rescue nil
          FileUtils.ln_s more_snippets_path, dest_snippets_path, :verbose => true
          puts 'Done.'
        end
      else
        puts 'No cool vim snippets. Skipping.'
      end
    end

    def dot_file_list
      @dot_file_list ||= Dir.glob(File.join(SOURCE_ROOT, '*'), File::FNM_DOTMATCH).find_all do |f|
        f !~ /backup|\.$|\.\.|.git$|.swp$|.gitmodules|install.(rb|thor)/ &&
        f =~ /\.[^\/]+$/
      end
    end

    def bins
      @bins ||= Dir[File.join SOURCE_ROOT, 'bin', '*']
    end

    def basenames
      basenames = dot_file_list.map do |f|
        File.basename f
      end

      basenames += bins.map do |f|
        File.join 'bin', (File.basename f)
      end
    end

    def vim_basenames
      %w[.vim .vimrc .bundles.vim]
    end

    def inflate_submodules
      `git submodule update --init`
    end
  end
end

DotsInstaller.start
