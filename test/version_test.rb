require File.join(File.dirname(__FILE__), 'test_helper')

class VersionTest < Test::Unit::TestCase
  context 'Versions' do
    setup do
      @user = User.create(:name => 'Stephen Richert')
      @user.update_attribute(:name, 'Steve Jobs')
      @user.update_attribute(:last_name, 'Richert')
      @first_version, @last_version = @user.versions.first, @user.versions.last
    end

    should 'be comparable to another version based on version iteration' do
      assert @first_version == @first_version
      assert @last_version == @last_version
      assert @first_version != @last_version
      assert @last_version != @first_version
      assert @first_version < @last_version
      assert @last_version > @first_version
      assert @first_version <= @last_version
      assert @last_version >= @first_version
    end

    should "not equal a separate model's version with the same iteration" do
      user = User.create(:name => 'Stephen Richert')
      user.update_attribute(:name, 'Steve Jobs')
      user.update_attribute(:last_name, 'Richert')
      first_version, last_version = user.versions.first, user.versions.last
      assert_not_equal @first_version, first_version
      assert_not_equal @last_version, last_version
    end

    should 'default to ordering by iteration when finding through association' do
      order = @user.versions.send(:scope, :find)[:order]
      assert_equal 'versions.iteration ASC', order
    end

    should 'return true for the "initial?" method when the version iteration is 1' do
      version = @user.versions.build(:iteration => 1)
      assert_equal 1, version.iteration
      assert_equal true, version.initial?
    end
  end
end
