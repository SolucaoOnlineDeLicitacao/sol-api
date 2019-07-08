class Supplier < ApplicationRecord
  include Supplier::Search
  include ::Sortable
  include ::Notifiable
  include ::PasswordSkippable

  mount_uploader :avatar, AvatarUploader

  versionable ignore: %i[
    confirmation_token confirmation_sent_at confirmed_at current_sign_in_at
    current_sign_in_ip last_sign_in_at last_sign_in_ip name phone
    remember_created_at reset_password_sent_at reset_password_token
    sign_in_count unconfirmed_email encrypted_password
  ]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :provider
  has_one :contract, as: :refused_by

  has_many :access_grants,
    -> { where 'scopes ~ :scope', scope: :supplier },
    class_name: 'Doorkeeper::AccessGrant',
    foreign_key: :resource_owner_id,
    dependent: :destroy

  has_many :access_tokens,
    -> { where 'scopes ~ :scope', scope: :supplier },
    class_name: 'Doorkeeper::AccessToken',
    foreign_key: :resource_owner_id,
    dependent: :destroy

  has_many :device_tokens, as: :owner, dependent: :destroy

  has_many :lot_proposals, dependent: :restrict_with_error

  validates :name,
            :cpf,
            :phone,
            presence: true

  validates :cpf, cpf: true
  validates :phone, phone: true

  delegate :name, to: :provider, prefix: true, allow_nil: true

  def self.default_sort_column
    'suppliers.name'
  end

  def text
    "#{name} / #{email}"
  end
end
