require "application_system_test_case"

class BacklinksTest < ApplicationSystemTestCase
  setup do
    @backlink = backlinks(:one)
  end

  test "visiting the index" do
    visit backlinks_url
    assert_selector "h1", text: "Backlinks"
  end

  test "should create backlink" do
    visit backlinks_url
    click_on "New backlink"

    fill_in "Anchor text", with: @backlink.anchor_text
    fill_in "Context text", with: @backlink.context_text
    fill_in "Domain", with: @backlink.domain_id
    fill_in "Meta description", with: @backlink.meta_description
    check "Nofollow" if @backlink.nofollow
    fill_in "Page title", with: @backlink.page_title
    fill_in "Rel attributes", with: @backlink.rel_attributes
    fill_in "Source domain", with: @backlink.source_domain
    fill_in "Source url", with: @backlink.source_url
    fill_in "Target domain", with: @backlink.target_domain
    fill_in "Target url", with: @backlink.target_url
    fill_in "User", with: @backlink.user_id
    click_on "Create Backlink"

    assert_text "Backlink was successfully created"
    click_on "Back"
  end

  test "should update Backlink" do
    visit backlink_url(@backlink)
    click_on "Edit this backlink", match: :first

    fill_in "Anchor text", with: @backlink.anchor_text
    fill_in "Context text", with: @backlink.context_text
    fill_in "Domain", with: @backlink.domain_id
    fill_in "Meta description", with: @backlink.meta_description
    check "Nofollow" if @backlink.nofollow
    fill_in "Page title", with: @backlink.page_title
    fill_in "Rel attributes", with: @backlink.rel_attributes
    fill_in "Source domain", with: @backlink.source_domain
    fill_in "Source url", with: @backlink.source_url
    fill_in "Target domain", with: @backlink.target_domain
    fill_in "Target url", with: @backlink.target_url
    fill_in "User", with: @backlink.user_id
    click_on "Update Backlink"

    assert_text "Backlink was successfully updated"
    click_on "Back"
  end

  test "should destroy Backlink" do
    visit backlink_url(@backlink)
    click_on "Destroy this backlink", match: :first

    assert_text "Backlink was successfully destroyed"
  end
end
