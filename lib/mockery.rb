module Mockumentary
  class Mockery < Hashie::Mash
    def self.ar_class
      @ar_class ||= infer_ar_class
    end

    def self.ar_class=(klass)
      @ar_class = klass
      introspect if klass
      klass
    end

    def self.infer_ar_class
      self.to_s.gsub(/^Mockumentary/, '').constantize
    end

    def self.uid
      @uid ||= 0
      @uid += 1
      @uid
    end

    def self.overrides
      {}
    end

    FAKERY_MAP = {
      :integer => :integer,
      :decimal => :decimal,
      :float => :decimal,
      :string => :words, 
      :text => :sentences,
      :datetime => :time, 
      :timestamp => :time, 
      :time => :time, 
      :date => :date, 
      :binary => :hash, 
      :boolean => false
    }

    def self.fake_data(key)
      case key
      when :words
        Faker::Lorem.words.join(' ')
      when :sentences
        Faker::Lorem.sentences.join(' ')
      when :integer
        rand(100)
      when :decimal
        rand * 100
      when :time
        Time.now + rand(60).days
      when :date
        Date.today + rand(60)
      when :hash
        Faker::Lorem.characters
      when :uid
        uid
      else
        key.respond_to?(:call) ? key.call : key
      end
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

    def self.save_fields
      @save_fields ||= [:id, :created_at, :updated_at]
    end

    def self.build(klass)
      Mockumentary.constantize(klass)
    rescue
      Mockumentary.generate(klass)
    end

    def self.relationships
      @relationships ||= {}
    end

    def self.reset_defaults
      @save_defaults = nil
      @mock_defaults = nil
      @uid = nil
    end

    def self.introspect
      reset_defaults

      # introspect columns
      ar_class.columns.each do |c|
        name = c.name.to_sym
        if save_fields.include?(name) 
          save_defaults[name] = FAKERY_MAP[c.type] if name != :id
        else
          mock_defaults[name] = FAKERY_MAP[c.type]
        end 
      end

      # introspect relationships
      ar_class.reflections.each do |name, reflection|
        attr_accessor name
        class_name = reflection.options[:class_name] || name.to_s.classify
        relationships[name] = lambda { Collection.new(build(class_name)) } if reflection.collection?
      end
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
  end
end
