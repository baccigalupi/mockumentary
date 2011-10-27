module Mockumentary
  class Model < Hashie::Mash
    DUMP_NAME = 'mockumentary.yml'
    
    def self.generate(klass)
      mock_class = constantize klass
      build klass unless mock_class
      mock_class ||= constantize klass
    end

    def self.init_defaults
      @init_defaults ||= {
        :new_record => true
      }
    end

    def self.mock_defaults
      @mock_defaults ||= {}
    end

    def self.save_defaults
      @save_defaults ||= {
        :new_record => false,
        :id => :uid
      }
    end

    def self.classes
      @classes ||= []
    end

    def self.build(klass)
      class_eval <<-RUBY
        class #{container_name}::#{klass} < #{container_name}; end
        classes << #{container_name}::#{klass}
      RUBY
    end

    def self.relationships
      @relationships ||= {}
    end

    def self.constantize(klass)
      classes.detect{|c| c.to_s == "#{container_name}::#{klass}"}
    end

    def self.uid
      @uid ||= 0
      @uid += 1
      @uid
    end

    def self.overrides
      {}
    end

    def self.fake_data(key)
      data = Mockumentary::Data.generate(key)
      
      unless data
        data  = if key == :uid
          uid
        elsif key.respond_to?(:call)
          key.respond_to?(:call) 
        else
          key
        end
      end

      data
    end

    def self.evaluate(opts)
      opts.inject({}) do |result, arr|
        result[arr.first] = fake_data(arr.last)
        result
      end
    end

    def self.mock_opts
      opts = init_defaults.dup
      opts.merge!(mock_defaults)
      opts.merge!(overrides[:mock]) if overrides && overrides[:mock]
      evaluate(opts)
    end

    def self.init_opts
      opts = init_defaults.dup
      opts.merge!(overrides[:init]) if overrides && overrides[:init]
      evaluate(opts)
    end

    def self.save_opts
      opts = save_defaults.dup
      opts.merge!(overrides[:save]) if overrides && overrides[:save]
      evaluate(opts)
    end

    def initialize(opts={})
      super(self.class.init_opts.merge(opts))
      self.class.relationships.each do |key, value|
        send("#{key}=", value.call)
      end
    end

    def self.mock(opts={})
      new(mock_opts.merge(opts))
    end

    def self.mock!(opts={})
      instance = mock(opts)
      instance.save(opts)
    end

    def save(opts={})
      self.class.save_opts.merge(opts).each do |key, value|
        self[key] = value
      end
      self
    end

    def self.save_fields
      @save_fields ||= [:id, :created_at, :updated_at]
    end
  end
end
