# frozen_string_literal: true

FactoryBot.define do
  factory :api_token do
    association :user
    token_digest { Digest::SHA256.hexdigest(SecureRandom.urlsafe_base64(32)) }
    name { 'Test Token' }
    last_used_at { nil }
    revoked_at { nil }

    trait :revoked do
      revoked_at { Time.current }
    end

    trait :used do
      last_used_at { 1.hour.ago }
    end

    trait :recently_used do
      last_used_at { 1.minute.ago }
    end
  end
end
