module Mockumentary
  module ActiveRecord
    def mock_class
      @mock_class ||= discover_mock_class!
    end

    def discover_mock_class!
      Mockery.classes.detect {|c| c.ar_class == self } || Mockery.generate(self)
    end

    def mock(opts={})
      mock_class.mock(opts)
    end

    def mock!(opts={})
      mock_class.mock!(opts)
    end

    def mew(opts={})
      mock_class.new(opts)
    end
  end
end
