module Mockumentary
  class Model < Hashie::Mash
    DUMP_NAME = 'mockumentary.yml'
    
    def self.generate(klass)
      begin mock_class = constantize klass
      rescue
        build klass
      end

      mock_class = constantize klass
    end

    # def self.build(klass)
    #   constantize(klass)
    # rescue
    #   generate(klass)
    # end

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
        class #{klass} < Mockery; end
        classes << #{self}::#{klass}
      RUBY
    end

    def self.constantize(klass)
      "#{self}::#{klass}".constantize
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
