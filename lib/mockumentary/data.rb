module Mockumentary
  module Data
    def self.generate(key)
      self.send(key) if key.is_a?(Symbol) && respond_to?(key) 
    end

    def self.string
      Faker::Lorem.words.join(' ')
    end

    def self.text
      Faker::Lorem.sentences.join(' ')
    end

    def self.integer
      rand(100)
    end

    def self.decimal
      rand * 100
    end

    def self.float
      decimal
    end

    def self.time
      Time.now + rand(60) * (3600*24)
    end

    def self.timestamp
      time
    end

    def self.datetime
      time
    end

    def self.date
      Date.today + rand(60) * (3600*24)
    end

    def self.binary
      Faker::Lorem.characters
    end

    def self.boolean
      false
    end

    def self.first_name
      Faker::Name.first_name
    end

    def self.last_name
      Faker::Name.last_name
    end

    def self.full_name
      "#{first_name} #{last_name}"
    end
  end
end
