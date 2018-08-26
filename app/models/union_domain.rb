# frozen_string_literal: true
# == Schema Information
#
# Table name: union_domains
#
#  id           :integer          not null, primary key
#  domain       :string
#  account_id   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bot          :boolean          default false
#

class UnionDomain < ApplicationRecord

  attr_accessor :retroactive

  validates :domain, presence: true, uniqueness: true, :unless => :account_id?
  validates :account_id, presence: true, uniqueness: true, :unless => :domain?

  belongs_to :account, inverse_of: :union_domains, optional: true

  has_many :accounts, foreign_key: :domain, primary_key: :domain
  delegate :count, to: :accounts, prefix: true

  scope :domain, -> { select('domain').where(account_id: nil) }
  scope :all_domain, -> { select('domain').uniq.where.not(domain: nil) }
  scope :user, -> { select('account_id').where.not(account_id: nil).where(bot: false) }
  scope :bots, -> { select('account_id').where.not(account_id: nil).where(bot: true) }

  def self.domain?(domain)
    UnionDomain.domain.where(domain: domain).exists?
  end

  def self.bot?(account_id)
    bots.where(account_id: account_id).exists?
  end

  before_validation :normalize_domain
  before_create :account_domain_copy, :if => :add_account?

  private

  def normalize_domain
    self.domain = TagManager.instance.normalize_domain(domain)
  end

  def add_account?
    account_id.present? && !bot?
  end

  def account_domain_copy
    self.domain = account.domain
  end
end
