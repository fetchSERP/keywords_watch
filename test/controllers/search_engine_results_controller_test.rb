require "test_helper"

class SearchEngineResultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @search_engine_result = search_engine_results(:one)
  end

  test "should get index" do
    get search_engine_results_url
    assert_response :success
  end

  test "should get new" do
    get new_search_engine_result_url
    assert_response :success
  end

  test "should create search_engine_result" do
    assert_difference("SearchEngineResult.count") do
      post search_engine_results_url, params: { search_engine_result: { description: @search_engine_result.description, keyword_id: @search_engine_result.keyword_id, ranking: @search_engine_result.ranking, site_name: @search_engine_result.site_name, title: @search_engine_result.title, url: @search_engine_result.url, user_id: @search_engine_result.user_id } }
    end

    assert_redirected_to search_engine_result_url(SearchEngineResult.last)
  end

  test "should show search_engine_result" do
    get search_engine_result_url(@search_engine_result)
    assert_response :success
  end

  test "should get edit" do
    get edit_search_engine_result_url(@search_engine_result)
    assert_response :success
  end

  test "should update search_engine_result" do
    patch search_engine_result_url(@search_engine_result), params: { search_engine_result: { description: @search_engine_result.description, keyword_id: @search_engine_result.keyword_id, ranking: @search_engine_result.ranking, site_name: @search_engine_result.site_name, title: @search_engine_result.title, url: @search_engine_result.url, user_id: @search_engine_result.user_id } }
    assert_redirected_to search_engine_result_url(@search_engine_result)
  end

  test "should destroy search_engine_result" do
    assert_difference("SearchEngineResult.count", -1) do
      delete search_engine_result_url(@search_engine_result)
    end

    assert_redirected_to search_engine_results_url
  end
end
