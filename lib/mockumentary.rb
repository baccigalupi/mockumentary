Bundler.require

module Mockumentary
  def self.introspect dir = "#{Rails.root}/app/models", namespace = ''
     Dir.chdir(dir) do 
      Dir['*.rb'].each do |file|
        require "#{dir}/#{file}"
        ar_class = (namespace + file.gsub(/\.rb$/, '').classify).constantize
        Mockery.generate(ar_class)
      end

      Dir['*'].each do |file|
        path = "#{dir}/#{file}"
        if File.directory?(path)
          namespace << "::" unless namespace.empty?
          namespace << "#{file.classify}::"
          introspect(path, namespace)
        end
      end
    end 
  end

  def self.dump dir = "#{Rails.root}/config"
    Mockery.dump
  end

  def self.load(dir=nil)
    Mocksimile.load(dir)
  end

  def self.load_and_release(dir=nil)
    load(dir)
    Mocksimile.release
  end
end

require 'mockumentary/data'
require 'mockumentary/collection'
require 'mockumentary/model'
require 'mockumentary/mockery'
require 'mockumentary/active_record'
require 'mockumentary/mocksimile'
