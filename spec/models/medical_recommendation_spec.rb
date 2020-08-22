require 'rails_helper'

RSpec.describe MedicalRecommendation, type: :model do
  let(:user) { create(:user) }
  subject    { build(:medical_recommendation, user_id: user.id) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a number" do
    subject.number = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without an issuer" do
    subject.issuer = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a state" do
    subject.state = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without an expiration_date" do
    subject.expiration_date = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without an image_url" do
    subject.image_url = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a user_id" do
    subject.user_id = nil
    expect(subject).to_not be_valid
  end

end

