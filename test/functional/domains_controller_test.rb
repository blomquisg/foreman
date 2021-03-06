require 'test_helper'

class DomainsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_index_json
    get :index, {:format => "json"}, set_session_user
    domain = ActiveSupport::JSON.decode(@response.body)
    assert !domain.empty?
    assert_response :success
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Domain.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Domain.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to domains_url
  end

  def test_create_valid_json
    Domain.any_instance.stubs(:valid?).returns(true)
    post :create, {:format => "json"}, set_session_user
    domain = ActiveSupport::JSON.decode(@response.body)
    assert_response :created
  end

  def test_edit
    get :edit, {:id => Domain.first.name}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Domain.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Domain.first.name}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Domain.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Domain.first.name}, set_session_user
    assert_redirected_to domains_url
  end

  def test_update_valid_json
    Domain.any_instance.stubs(:valid?).returns(true)
    put :update, {:format => "json", :id => Domain.first.name}, set_session_user
    domain = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
  end

  def test_destroy
    domain = Domain.first
    domain.hosts.clear
    domain.subnets.clear
    delete :destroy, {:id => domain.name}, set_session_user
    assert_redirected_to domains_url
    assert !Domain.exists?(domain.id)
  end

  def test_destroy_json
    domain = Domain.first
    domain.hosts.clear
    domain.subnets.clear
    delete :destroy, {:format => "json", :id => domain.name}, set_session_user
    domain = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Domain.exists?(:name => domain['id'])
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  def user_with_viewer_rights_should_fail_to_edit_a_domain
    setup_users
    get :edit, {:id => Domain.first.id}
    assert @response.status == '403 Forbidden'
  end

  def user_with_viewer_rights_should_succeed_in_viewing_domains
    setup_users
    get :index
    assert_response :success
  end
end
