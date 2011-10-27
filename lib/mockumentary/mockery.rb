class Mockery < Mockumentary::Model
  def self.ar_class
    @ar_class ||= infer_ar_class
  end

  def self.ar_class=(klass)
    @ar_class = klass
    introspect if klass
    klass
  end

  def self.container_name
    "Mockery"
  end

  def self.infer_ar_class
    self.to_s.gsub(/^#{container_name}/, '').constantize
  end

  def self.build(klass)
    super
    class_eval "#{container_name}::#{klass}.ar_class = ::#{klass}"
  end

  def self.reset_defaults
    @relationships = nil
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
        save_defaults[name] = c.type if name != :id
      else
        mock_defaults[name] = c.type
      end 
    end

    # introspect relationships
    ar_class.reflections.each do |name, reflection|
      attr_accessor name
      class_name = reflection.options[:class_name] || name.to_s.classify
      relationships[name] = lambda { Mockumentary::Collection.new(build(class_name)) } if reflection.collection?
    end
  end

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

      relationships = klass.relationships.inject({}) do |result, array|
        key = array.first
        value = array.last # a lambda 
        relationship_type = value.call.type.to_s.gsub(/^Mockery::/, '')        
        result[key] = relationship_type
        result
      end

      result[klass.ar_class.to_s] = {
        :init => init,
        :save => save,
        :mock => mock,
        :relationships => relationships
      }
      result
    end
  end
end
