Bundler.require

module Mockumentary
  def self.generate(klass)
    begin mock_class = constantize klass
    rescue  
      build klass
    end

    mock_class = constantize klass
  end

  def self.classes
    @classes ||= []
  end

  def self.build(klass)
    class_eval <<-RUBY
      class #{klass} < Mockumentary::Mockery; end
      #{klass}.ar_class = ::#{klass}
      classes << Mockumentary::#{klass}
    RUBY
  end

  def self.constantize(klass)
    "Mockumentary::#{klass}".constantize
  end

  def self.introspect dir = "#{Rails.root}/app/models", namespace = ''
     Dir.chdir(dir) do 
      Dir['*.rb'].each do |file|
        require "#{dir}/#{file}"
        ar_class = (namespace + file.gsub(/\.rb$/, '').classify).constantize
        generate(ar_class)
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

  DUMP_NAME = 'mockumentary.yml'
  def self.dump dir = "#{Rails.root}/config"
    File.open("#{dir}/#{DUMP_NAME}", 'w') do |f|
      f.write(YAML.dump(data_dump))
    end
  end

  def self.data_dump
    classes.inject({}) do |result, klass|
      init = klass.init_defaults.dup
      init.merge!(klass.overrides[:init]) if klass.overrides && klass.overrides[:init]
      
      save = klass.save_defaults.dup
      save.merge!(klass.overrides[:save]) if klass.overrides && klass.overrides[:save]

      mock = klass.mock_defaults.dup
      mock.merge!(klass.overrides[:mock]) if klass.overrides && klass.overrides[:mock]

      result[klass.ar_class.to_s] = {
        :init => init,
        :save => save,
        :mock => mock
      }
      result
    end
  end
end

require 'data'
require 'collection'
require 'mockery'
require 'mocksimile'
