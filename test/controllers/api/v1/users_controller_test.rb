# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class UsersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @api_v1_user = api_v1_users(:one)
      end

      test 'should get index' do
        get api_v1_users_url
        assert_response :success
      end

      test 'should get new' do
        get new_api_v1_user_url
        assert_response :success
      end

      test 'should create api_v1_user' do
        assert_difference('Api::V1::User.count') do
          post api_v1_users_url,
               params: { api_v1_user: { last_logged_in: @api_v1_user.last_logged_in, name: @api_v1_user.name,
                                        password: @api_v1_user.password, uid: @api_v1_user.uid } }
        end

        assert_redirected_to api_v1_user_url(Api::V1::User.last)
      end

      test 'should show api_v1_user' do
        get api_v1_user_url(@api_v1_user)
        assert_response :success
      end

      test 'should get edit' do
        get edit_api_v1_user_url(@api_v1_user)
        assert_response :success
      end

      test 'should update api_v1_user' do
        patch api_v1_user_url(@api_v1_user),
              params: { api_v1_user: { last_logged_in: @api_v1_user.last_logged_in, name: @api_v1_user.name,
                                       password: @api_v1_user.password, uid: @api_v1_user.uid } }
        assert_redirected_to api_v1_user_url(@api_v1_user)
      end

      test 'should destroy api_v1_user' do
        assert_difference('Api::V1::User.count', -1) do
          delete api_v1_user_url(@api_v1_user)
        end

        assert_redirected_to api_v1_users_url
      end
    end
  end
end
