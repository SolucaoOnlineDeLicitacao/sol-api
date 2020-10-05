class User < ApplicationRecord
  include User::Search
  include ::Sortable
  include ::Notifiable
  include ::PasswordSkippable
  include ::I18nable

  mount_uploader :avatar, AvatarUploader

  versionable ignore: %i[
    confirmation_token confirmation_sent_at confirmed_at current_sign_in_at
    current_sign_in_ip last_sign_in_at last_sign_in_ip name phone
    remember_created_at reset_password_sent_at reset_password_token
    sign_in_count unconfirmed_email encrypted_password
  ]

  attr_accessor :skip_integration_validations

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :cooperative
  belongs_to :role, optional: true

  has_many :access_grants,
    -> { where 'scopes ~ :scope', scope: :user },
    class_name: 'Doorkeeper::AccessGrant',
    foreign_key: :resource_owner_id,
    dependent: :destroy

  has_many :access_tokens,
    -> { where 'scopes ~ :scope', scope: :user },
    class_name: 'Doorkeeper::AccessToken',
    foreign_key: :resource_owner_id,
    dependent: :destroy

  has_many :device_tokens, as: :owner, dependent: :destroy

  validates :name,
            :cpf,
            presence: true

  validates :cpf, cpf: true

  delegate :title, :id, to: :role, prefix: true, allow_nil: true
  delegate :name, to: :cooperative, prefix: true, allow_nil: true

  def self.default_sort_column
    'users.name'
  end

  def text
    "#{name} / #{email}"
  end

  def skip_integration_validations!
    @skip_integration_validations = true
  end
end
