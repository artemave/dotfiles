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
    install_dot_files
    setup_vim
    #install_rbenv
  end

  desc 'install_dot_files', "installs dot files only"
  def install_dot_files
    inflate_submodules
    backup basenames
    deploy_dot_files basenames
  end

  desc 'setup_vim', 'installs only Vim bits and bobs'
  def setup_vim
    vundlize
  end

  desc 'install_rbenv', 'install rbenv and plugins'
  def install_rbenv
    rbenv_source  = File.join SOURCE_ROOT, 'rbenv'
    rbenv_home    = File.join HOME_DIR, '.rbenv'

    `git clone git://github.com/sstephenson/rbenv.git #{rbenv_home}`

    rbenv_plugins

    backup [File.join(rbenv_home, 'default-gems'), File.join(rbenv_home, 'vars')]

    FileUtils.ln_s((File.join rbenv_source, 'default-gems'), File.join(rbenv_home, 'default-gems'), :verbose => true)
    FileUtils.ln_s((File.join rbenv_source, 'vars'), File.join(rbenv_home, 'vars'), :verbose => true)
  end

  desc 'rbenv_plugins', 'install or update rbenv plugins'
  def rbenv_plugins
    rbenv_home    = File.join HOME_DIR, '.rbenv'
    rbenv_plugins = File.join rbenv_home, 'plugins'

    FileUtils.mkdir_p rbenv_plugins, :verbose => true

    %w[
      sstephenson/ruby-build
      tpope/rbenv-ctags
      sstephenson/rbenv-default-gems
      tpope/rbenv-aliases
      tpope/rbenv-readline
      sstephenson/rbenv-vars
      sstephenson/rbenv-gem-rehash
    ].each do |plugin|
      plugin_name = plugin[/\/(.*?)$/, 1]
      dest_path = File.join rbenv_plugins, plugin_name
      begin
        FileUtils.cd dest_path, :verbose => true
        puts `git pull`
      rescue
        puts `git clone git://github.com/#{plugin}.git #{dest_path}`
      end
    end
    FileUtils.cd File.expand_path(File.dirname __FILE__), :verbose => true
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
        FileUtils.ln_s((File.join SOURCE_ROOT, basename), File.join(HOME_DIR, prefix), :verbose => true)
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
