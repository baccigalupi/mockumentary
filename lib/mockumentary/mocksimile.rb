class Mocksimile < Mockumentary::Model
  def self.generate(ar_class_name, opts=nil)
    mock_class = super(ar_class_name)
    mock_class.defaulterize(opts) if opts
    mock_class
  end

  def self.defaulterize(opts)
    @init_defaults = opts[:init]
    @mock_defaults = opts[:mock]
    @save_defaults = opts[:save]
    build_relationships(opts[:relationships])
  end

  def self.build_relationships(opts)
    @relationships = opts.inject({}) do |result, arr|
      key = arr.first
      klass = generate( arr.last )
      result[key] = lambda { Mockumentary::Collection.new(klass) }

      result
    end
  end

  def self.container_name
    "Mocksimile"
  end

  def self.load(dir=nil)
    unless dir
      dir = if defined?(Rails) 
              Rails.root
            elsif defined?(RAILS_ROOT)
              RAILS_ROOT
            else
              ''
            end
    end

    path =  "#{dir}/config/#{DUMP_NAME}"
    unless File.exist?(path)
      raise ArgumentError, "Could not find mockumentary.yml. Please include a path or define RAILS_ROOT"
    end
    config = YAML.load(File.read(path))
    config.each{ |klass_name, options| Mocksimile.generate(klass_name, options) }
  end

end
