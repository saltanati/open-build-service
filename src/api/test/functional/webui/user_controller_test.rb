require 'test_helper'

class Webui::UserControllerTest < Webui::IntegrationTest

  def test_edit
    login_king
    visit '/webui2/configuration/users/tom'

    fill_in "realname", with: "Tom Thunder"
    click_button "Update"
    
    find('#flash-messages').must_have_text("User data for user 'tom' successfully updated.")
  end

end