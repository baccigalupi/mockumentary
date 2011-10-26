module Mockumentary
  class Collection < Array
    attr_accessor :type
  
    def initialize(klass)
      self.type = klass
    end

    def mock(i=1)
      (1..i).each { self << type.mock }
      self
    end

    def mock!(i=1)
      (1..i).each { self << type.mock! }
      self
    end

    def build(opts={})
      self << type.new(opts)
      self
    end

    def create(opts={})
      self << type.new(opts).save
      self
    end

    alias :create! :create

    def delete(*args)
      args.each {|e| super(e)}
      self
    end

    alias :delete_all :clear
    alias :destroy_all :clear
    alias :reset :clear

    def exist?(element)
      map(&:id).include?(element.id)
    end
  end
end

