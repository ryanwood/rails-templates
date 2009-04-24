# Sets up authentication using AuthLogic
# Depends on HAML

gem 'authlogic'

# Session
generate(:session, "user_session")
generate(:controller, "user_session") # Call generate mainly for the tests

# Session Controller
file "app/controllers/user_session_controller.rb", <<CODE
class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to account_url
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to new_user_session_url
  end
end
CODE

# Login Form
file "app/views/user_session/new.html.haml", <<CODE
- form_for @user_session do |f|
  = f.error_messages
  %p
    = f.label :login
    %br
    = f.text_field :login
  %p
    = f.label :password
    %br
    = f.text_field :password
  %p
    = f.submit "Login"
CODE

# User Management
generate(:controller, "user")
generate(:model, "user --skip-migration --skip-fixture")

file "app/models/user.rb", <<CODE
class User < ActiveRecord::Base
  acts_as_authentic
end
CODE

# User Views
file "app/views/user/_form.html.haml", <<CODE
%p
  = form.label :first_name
  %br
  = form.text_field :first_name
%p
  = form.label :last_name
  %br
  = form.text_field :last_name
%p
  = form.label :login
  %br
  = form.text_field :login
%p
  = form.label :password, form.object.new_record? ? nil : "Change password"
  %br
  = form.password_field :password
%p
  = form.label :password_confirmation
  %br
  = form.password_field :password_confirmation
CODE

file "app/views/user/new.html.haml", <<CODE
%h1 Register
 
- form_for @user, :url => account_path do |f|
  = f.error_messages
  = render :partial => "form", :object => f
  = f.submit "Register"
CODE

file "app/views/user/edit.html.haml", <<CODE
%h1 Edit my Account
 
- form_for @user, :url => account_path do |f|
  = f.error_messages
  = render :partial => "form", :object => f
  = f.submit "Update"
%p= link_to "My Profile", account_path
CODE

file "app/views/user/show.html.haml", <<CODE
%p
  %strong Login:
  =h @user.login
%p
  %strong Login Count:
  =h @user.login_count
%p
  %strong Last request at:
  =h @user.last_request_at
%p
  %strong Last login at:
  =h @user.last_login_at
%p
  %strong Current login at::
  =h @user.current_login_at
%p
  %strong Last login ip:
  =h @user.last_login_ip 
%p
  %strong Current login ip:
  =h @user.current_login_ip  
%p= link_to 'Edit', edit_account_path
CODE

# Create user migration manually for User
file "db/migrations/#{Time.now.strftime('%Y%m%d%H%M%S')}_create_users.rb", <<CODE
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :first_name
      t.string    :last_name
      t.string    :login,               :null => false                # optional, you can use email instead, or both
      t.string    :email,               :null => false                # optional, you can use login instead, or both
      t.string    :crypted_password,    :null => false                # optional, see below
      t.string    :password_salt,       :null => false                # optional, but highly recommended
      t.string    :persistence_token,   :null => false                # required
      t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
      t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability

      # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
      t.integer   :login_count,         :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.integer   :failed_login_count,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_request_at                                    # optional, see Authlogic::Session::MagicColumns
      t.datetime  :current_login_at                                   # optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_login_at                                      # optional, see Authlogic::Session::MagicColumns
      t.string    :current_login_ip                                   # optional, see Authlogic::Session::MagicColumns
      t.string    :last_login_ip                                      # optional, see Authlogic::Session::MagicColumns
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
CODE

# Update application_controller.rb
gsub_file "app/controllers/application_controller.rb", /^end/i do |match|
  "  helper_method :current_user_session, :current_user

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
#{match}"
end