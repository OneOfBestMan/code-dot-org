# -*- coding: utf-8 -*-
require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test 'login error derives locale from cdo.locale' do
    locale = 'es-ES'
    @request.env['cdo.locale'] = locale
    post :create
    assert_select '.alert', I18n.t('devise.failure.not_found_in_database', :locale => locale)
  end

  test "teachers go to teacher dashboard after signing in" do
    teacher = create(:teacher)

    post :create, user: {login: '', hashed_email: teacher.hashed_email, password: teacher.password}

    assert_signed_in_as teacher
    assert_redirected_to '//test.code.org/teacher-dashboard'
  end

  test "students go to learn homepage after signing in" do
    student = create(:student)

    post :create, user: {login: '', hashed_email: student.hashed_email, password: student.password}

    assert_signed_in_as student
    assert_redirected_to '/'
  end

  test "sign in page saves return to url in session" do
    get :new, return_to: (return_to = "http://code.org/a-return-to-url")

    assert_equal return_to, session[:return_to]
  end

  test "teachers go to specified return to url after signing in" do
    teacher = create(:teacher)

    session[:return_to] = return_to = '//test.code.org/the-return-to-url'

    post :create, user: {login: '', hashed_email: teacher.hashed_email, password: teacher.password}

    assert_signed_in_as teacher
    assert_redirected_to return_to
  end

  test 'signing in as user via username' do
    user = create(:user, birthday: Date.new(2010, 1, 3), email: 'my@email.xx')

    post :create, user: {login: user.username, hashed_email: '', password: user.password}

    assert_signed_in_as user
    assert_redirected_to '/'
  end

  test 'signing in as student via hashed_email' do
    student = create(:student, birthday: Date.new(2010, 1, 3), email: 'my@email.xx')

    post :create, user: {login: '', hashed_email: student.hashed_email, password: student.password}

    assert_signed_in_as student
    assert_redirected_to '/'
  end

  test 'signing in new user creates UserGeo' do
    user = create(:user)

    assert UserGeo.find_by_user_id(user.id).nil?

    post :create, user: {
      login: '', hashed_email: user.hashed_email, password: user.password
    }

    assert UserGeo.find_by_user_id(user.id)
  end

  test 'signing in user with UserGeo does not modify UserGeo' do
    user = create(:user, current_sign_in_ip: '1.2.3.4')
    UserGeo.create(
      user_id: user.id,
      ip_address: '9.8.7.6',
      indexed_at: '2000-01-02 12:34:56'
    )

    post :create, user: {
      login: '', hashed_email: user.hashed_email, password: user.password
    }

    assert_equal '9.8.7.6', UserGeo.find_by_user_id(user.id)[:ip_address]
  end

  test 'failed signin does not create UserGeo' do
    user = create(:user)

    assert_no_change('UserGeo.count') do
      post :create, user: {
        login: '', hashed_email: user.hashed_email, password: 'wrong password'
      }
    end
  end

  test "users go to code.org after logging out" do
    student = create(:student)
    sign_in student

    delete :destroy

    assert_redirected_to '//test.code.org'
  end

  test "if you're not signed in you can still sign out" do
    delete :destroy

    assert_redirected_to '//test.code.org'
  end

  test "facebook users go to oauth sign out page after logging out" do
    student = create(:student, provider: :facebook)
    sign_in student

    delete :destroy

    assert_redirected_to '/oauth_sign_out/facebook'
  end

  test "google account users go to oauth sign out page after logging out" do
    student = create(:student, provider: :google_oauth2)
    sign_in student

    delete :destroy

    assert_redirected_to '/oauth_sign_out/google_oauth2'
  end

  test "microsoft account users go to oauth sign out page after logging out" do
    student = create(:student, provider: :windowslive)
    sign_in student

    delete :destroy

    assert_redirected_to '/oauth_sign_out/windowslive'
  end

  test "oauth sign out page for facebook" do
    get :oauth_sign_out, provider: 'facebook'
    assert_select 'a[href="https://www.facebook.com/logout.php"]'
    assert_select 'h4', 'You used Facebook to sign in. Click here to sign out of Facebook.'
  end

  test "oauth sign out page for google account" do
    get :oauth_sign_out, provider: 'google_oauth2'
    assert_select 'a[href="https://accounts.google.com/logout"]'
    assert_select 'h4', 'You used Google Account to sign in. Click here to sign out of Google Account.'
  end

  test "oauth sign out page for microsoft account" do
    get :oauth_sign_out, provider: 'windowslive'
    assert_select 'a[href="http://login.live.com/logout.srf"]'
    assert_select 'h4', 'You used Microsoft Account to sign in. Click here to sign out of Microsoft Account.'
  end

  test "deleted user cannot sign in" do
    teacher = create(:teacher)
    teacher.deleted_at = Time.now # 'delete' the user
    teacher.save!

    post :create, user: {login: '', hashed_email: teacher.hashed_email, password: teacher.password}

    assert_signed_in_as nil
  end

  test "session cookie set if remember me not checked" do
    teacher = create(:teacher)

    post :create, user: {login: '', hashed_email: teacher.hashed_email, password: teacher.password}

    assert_nil @response.cookies["remember_user_token"]
  end

  test "persistent cookie set if remember me is checked" do
    teacher = create(:teacher)

    post :create, user: {login: '', hashed_email: teacher.hashed_email, password: teacher.password, remember_me: '1'}

    assert @response.cookies["remember_user_token"]
  end
end
