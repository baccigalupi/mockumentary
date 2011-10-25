module Mockumentary
  module Data
    def self.generate(key)
      begin
        klass = "Mockumentary::Data::#{key.to_s.classify}".constantize
        klass.generate
      rescue
      end
    end

    module String
      def self.generate
        Faker::Lorem.words.join(' ')
      end
    end

    module Text
      def self.generate
        Faker::Lorem.sentences.join(' ')
      end
    end

    module Integer
      def self.generate
        rand(100)
      end
    end

    module Decimal
      def self.generate
        rand * 100
      end
    end

    Float = Decimal

    module Time
      def self.generate
        ::Time.now + rand(60).days
      end
    end

    Timestamp = Time
    Datetime = Time

    module Date
      def self.generate
        ::Date.today + rand(60)
      end
    end

    module Binary
      def self.generate
        Faker::Lorem.characters
      end
    end

    module Boolean
      def self.generate
        false
      end
    end

    module FirstName
      def self.generate
        Faker::Name.first_name
      end
    end

    module LastName
      def self.generate
        Faker::Name.last_name
      end
    end

    module FullName
      def self.generate
        "#{FirstName.generate} #{LastName.generate}"
      end
    end
  end
end
