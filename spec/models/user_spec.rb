require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.save' do
    it 'saves an user when all the required fields are provided' do
      user = User.new(email: 'rafaelchacon@gmail.com',
                      password: '123456',
                      username: 'rafael')
      expect(user.save).to eq(true)
    end

    it 'generates uuid on user creation' do
      user = User.new(email: 'rafaelchacon@gmail.com',
                      password: '123456',
                      username: 'rafael')
      user.save!
      expect(user.uuid).to_not be_nil
      expect(user.uuid).to match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
    end

    it "doesn't save user when email is not provied" do
      user = User.new(password: '123456',
                      username: 'rafael')
      expect(user).to_not be_valid
      expect(user.errors.full_messages).to eq(['Email should look like an email address.'])
    end

    it "doesn't save user when password is not provied" do
      user = User.new(email: 'rafaelchacon@gmail.com',
                      username: 'rafael')
      expect(user).to_not be_valid
      expect(user.errors.full_messages).to eq(['Password is too short (minimum is 4 characters)'])
    end

    it "doesn't save user when username is not provied" do
      user = User.new(email: 'rafaelchacon@gmail.com',
                      password: '123456',
                      username: 'ab')
      expect(user).to_not be_valid
      expect(user.errors.full_messages).to eq(['Username is too short (minimum is 3 characters)'])
    end

    it "doesn't save user when username has spaces" do
      user = User.new(email: 'rafaelchacon@gmail.com',
                      password: '123456',
                      username: 'ab das dasd')
      expect(user).to_not be_valid
      expect(user.errors.full_messages).to eq(['Username is invalid'])
    end

    it "doesn't save user when profile bio contains numbers" do
      user = User.new(email: 'rafaelchacon@gmail.com',
                      password: '123456',
                      username: 'rafael')
      user.save!
      user.profile.first_name = 'jose'
      user.profile.bio = '123'
      expect(user.profile).to_not be_valid
      expect(user.profile.errors.full_messages).to eq(['Bio is invalid'])
    end

    it 'name returns username when first_name is not present' do
      user = User.new(email: 'rafaelchacon@gmail.com',
                      password: '123456',
                      username: 'rafael')
      user.save!
      expect(user.name).to eq('rafael')
    end

    it 'name returns FirstName when  first_name is present' do
      user = User.new(email: 'rafaelchacon@gmail.com',
                      password: '123456',
                      username: 'rafael')
      user.save!
      user.profile.first_name = 'jose'
      user.profile.save!
      expect(user.name).to eq('Jose')
    end

  end
end
