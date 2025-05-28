require "test_helper"

class BacklinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @backlink = backlinks(:one)
  end

  test "should get index" do
    get backlinks_url
    assert_response :success
  end

  test "should get new" do
    get new_backlink_url
    assert_response :success
  end

  test "should create backlink" do
    assert_difference("Backlink.count") do
      post backlinks_url, params: { backlink: { anchor_text: @backlink.anchor_text, context_text: @backlink.context_text, domain_id: @backlink.domain_id, meta_description: @backlink.meta_description, nofollow: @backlink.nofollow, page_title: @backlink.page_title, rel_attributes: @backlink.rel_attributes, source_domain: @backlink.source_domain, source_url: @backlink.source_url, target_domain: @backlink.target_domain, target_url: @backlink.target_url, user_id: @backlink.user_id } }
    end

    assert_redirected_to backlink_url(Backlink.last)
  end

  test "should show backlink" do
    get backlink_url(@backlink)
    assert_response :success
  end

  test "should get edit" do
    get edit_backlink_url(@backlink)
    assert_response :success
  end

  test "should update backlink" do
    patch backlink_url(@backlink), params: { backlink: { anchor_text: @backlink.anchor_text, context_text: @backlink.context_text, domain_id: @backlink.domain_id, meta_description: @backlink.meta_description, nofollow: @backlink.nofollow, page_title: @backlink.page_title, rel_attributes: @backlink.rel_attributes, source_domain: @backlink.source_domain, source_url: @backlink.source_url, target_domain: @backlink.target_domain, target_url: @backlink.target_url, user_id: @backlink.user_id } }
    assert_redirected_to backlink_url(@backlink)
  end

  test "should destroy backlink" do
    assert_difference("Backlink.count", -1) do
      delete backlink_url(@backlink)
    end

    assert_redirected_to backlinks_url
  end
end
