class Registration
  include ActiveModel::SecurePassword,
          ActiveModel::Model,
          ActiveModel::Serializers::JSON

  validates :password, length: { in: 6..32 }
  validates :password_confirmation, presence: true
  has_secure_password
  attr_accessor :first_name, :last_name, :user_name, :password_digest

  def attributes
    { 'password_digest' => nil, 'first_name' => nil, 'last_name' => nil,
      'user_name' => nil
    }
  end
end
