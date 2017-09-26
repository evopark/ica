# frozen_string_literal: true

FactoryGirl.define do
  factory :operator_company, class: OperatorCompany do
  end

  factory :parking_garage, class: ICA.parking_garage_class do
    sequence(:name) { |n| format('Test Garage %d', n) }
    association :operator_company, strategy: :build
    system_type 'ica'
  end

  factory :user, class: User do
    brand 'evopark'
    sequence(:email) { |n| "user#{n}@evopark.de" }
    sequence(:customer_number) { |n| format('%05d', 12_345 + n) }
    feature_set_id { (1..10).to_a.sample }

    association :current_invoice_address, strategy: :build, factory: :invoice_address

    trait :confirmed do
      workflow_state :confirmed
      after(:build) do |user|
        user.rfid_tags = build(:rfid_tag, :active)
      end
    end

    trait :evopark do
      # it's the default
    end

    trait :easy_to_park do
      brand 'easy_to_park'
    end
  end

  factory :rfid_tag, class: RfidTag do
    workflow_state 'unused'
    sequence(:tag_number) { |n| format('%09d', 9_999_999 - n) }
    uid { "E200341201#{SecureRandom.hex(7).upcase}" }

    trait :active do
      workflow_state 'active'
    end

    trait :inactive do
      workflow_state 'inactive'
    end
  end

  factory :parking_card_add_on, class: ParkingCardAddOn do
    sequence(:identifier) { |n| format('%09d', n) }
    provider 'legic_prime'

    trait(:foreign_provider) do
      provider :shell
    end
  end

  factory :invoice_address, class: InvoiceAddress do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gender { InvoiceAddress.genders.keys.sample }
    academic_title { InvoiceAddress.academic_titles.keys.sample }
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    zip_code { Faker::Address.zip }
    country_code 'de'
    default true
  end

  factory :test_group, class: TestGroup do
    system_types ['ica']
    garage_status 'always'
    trait :evopark do
      system_types ['evopark']
    end
  end

  factory :blocklist_entry, class: BlocklistEntry do
  end
end
