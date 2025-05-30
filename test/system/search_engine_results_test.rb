require "application_system_test_case"

class SearchEngineResultsTest < ApplicationSystemTestCase
  setup do
    @search_engine_result = search_engine_results(:one)
  end

  test "visiting the index" do
    visit search_engine_results_url
    assert_selector "h1", text: "Search engine results"
  end

  test "should create search engine result" do
    visit search_engine_results_url
    click_on "New search engine result"

    fill_in "Description", with: @search_engine_result.description
    fill_in "Keyword", with: @search_engine_result.keyword_id
    fill_in "Ranking", with: @search_engine_result.ranking
    fill_in "Site name", with: @search_engine_result.site_name
    fill_in "Title", with: @search_engine_result.title
    fill_in "Url", with: @search_engine_result.url
    fill_in "User", with: @search_engine_result.user_id
    click_on "Create Search engine result"

    assert_text "Search engine result was successfully created"
    click_on "Back"
  end

  test "should update Search engine result" do
    visit search_engine_result_url(@search_engine_result)
    click_on "Edit this search engine result", match: :first

    fill_in "Description", with: @search_engine_result.description
    fill_in "Keyword", with: @search_engine_result.keyword_id
    fill_in "Ranking", with: @search_engine_result.ranking
    fill_in "Site name", with: @search_engine_result.site_name
    fill_in "Title", with: @search_engine_result.title
    fill_in "Url", with: @search_engine_result.url
    fill_in "User", with: @search_engine_result.user_id
    click_on "Update Search engine result"

    assert_text "Search engine result was successfully updated"
    click_on "Back"
  end

  test "should destroy Search engine result" do
    visit search_engine_result_url(@search_engine_result)
    click_on "Destroy this search engine result", match: :first

    assert_text "Search engine result was successfully destroyed"
  end
end
