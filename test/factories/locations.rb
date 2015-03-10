require 'ffaker'

FactoryGirl.define do
  factory :location do
    # required
    sequence(:street) { |n| "Foobar #{n}" }
    sequence(:zip) { |n| n.to_s.rjust(5, '0') }
    city 'Berlin'
    hq { rand(9) == 0 }

    latitude { rand 52.4..52.6 } # somewhere within approximate bounds of Berlin
    longitude { rand 13.25..13.6 }

    # optional
    sequence(:name) { |n| maybe(Faker::NameDE.name + n.to_s) }
    addition do
      maybe [
        "#{rand(1..3)}. Hinterhof",
        "#{rand(1..10)}. Stock",
        "Raum #{rand(1..20)}"
      ].sample
    end

    # associations
    organization
    federal_state { FederalState.select(:id).all.sample || FederalState.create(name: 'Berlin') }

    trait :fake_address do
      street { Faker::AddressDE.street_address }
      zip { (10_000..14_100).to_a.sample }
    end

    trait :hq do
      hq true
    end
  end
end

def maybe result
  rand(2) == 0 ? nil : result
end
