require 'test_helper'

class FavoritesControllerTest < ActionDispatch::IntegrationTest
   test "should not add to faves without user id" do
     fave = Favorite.new
     assert_not fave.save
   end
end
