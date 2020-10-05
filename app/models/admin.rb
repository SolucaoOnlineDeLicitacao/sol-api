class Admin < ApplicationRecord
  include Admin::Search
  include ::Sortable
  include ::Notifiable
  include ::PasswordSkippable
  include ::I18nable

  versionable ignore: %i[
    confirmation_token confirmation_sent_at confirmed_at current_sign_in_at
    current_sign_in_ip last_sign_in_at last_sign_in_ip name phone
    remember_created_at reset_password_sent_at reset_password_token
    sign_in_count unconfirmed_email
  ]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: { viewer: 0, reviewer: 1, general: 2 }

  has_many :access_grants,
    -> { where 'scopes ~ :scope', scope: :admin },
    class_name: 'Doorkeeper::AccessGrant',
    foreign_key: :resource_owner_id,
    dependent: :destroy

  has_many :access_tokens,
    -> { where 'scopes ~ :scope', scope: :admin },
    class_name: 'Doorkeeper::AccessToken',
    foreign_key: :resource_owner_id,
    dependent: :destroy

  has_many :covenants, dependent: :restrict_with_error

  has_one :contract, as: :refused_by

  validates :name, presence: true

  def self.default_sort_column
    'admins.name'
  end

  def text
    "#{name} / #{email}"
  end
end
