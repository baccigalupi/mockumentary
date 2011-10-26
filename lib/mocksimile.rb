class Mocksimile < Mockumentary::Model
  def self.generate(ar_class_name, opts)
    mock_class = super(ar_class_name)
    mock_class.defaulterize(opts)
  end

  def self.defaulterize(opts)
    @init_defaults = opts[:init]
    @mock_defaults = opts[:mock]
    @save_defaults = opts[:save]
    # relationships should be in here too
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
