class User < ActiveRecord::Base
  validates_presence_of :username, :password, :name
  has_secure_password
  has_one :bracket
end
