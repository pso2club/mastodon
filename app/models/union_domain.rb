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
#

class UnionDomain < ApplicationRecord

  attr_accessor :retroactive

  validates :domain, presence: true, uniqueness: true, :unless => :account_id?
  validates :account_id, presence: true, uniqueness: true, :unless => :domain?

  belongs_to :account, inverse_of: :union_domains, optional: true

  # has_many :accounts, foreign_key: :domain, primary_key: :domain
  # delegate :count, to: :accounts, prefix: true

  scope :domain, -> { select('domain').where.not(domain: nil) }
  scope :user, -> { select('account_id').where.not(account_id: nil) }

  def self.domain?(domain)
    where(domain: domain).exists?
  end

  def self.user?(user)
    Follow.where(account_id: self.user, target_account_id: user).exists?
  end

  def self.unionizer
    Follow.select('target_account_id').where(account_id: user)
  end

  before_validation :normalize_domain

  private

  def normalize_domain
    self.domain = TagManager.instance.normalize_domain(domain)
  end
end
