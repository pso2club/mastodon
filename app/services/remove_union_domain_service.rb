# frozen_string_literal: true

class RemoveUnionDomainService < BaseService
  attr_accessor :union_domain

  def call(union_domain, retroactive)
    @union_domain = union_domain
    process_retroactive_updates if retroactive
    union_domain.destroy
  end

  def process_retroactive_updates
    if union_domain.bot?
      bot_accounts!
    elsif union_domain.account_id.present?
      union_member!
    else
      union_accounts!
    end
  end

  def union_accounts!
    union_domain_accounts.in_batches.update_all(unionmember: false)
  end

  def union_member!
    Account.update(union_domain.account_id, { :unionmember => false })
  end

  def bot_accounts!
    bot_followed_accounts.in_batches.update_all(unionmember: false)
  end

  def bot_follows
    Follow.select(:target_account_id).where(account_id: union_domain.account.id)
  end

  def bot_followed_accounts
    Account.where(id: bot_follows)
  end

  def union_domain_accounts
    Account.where(domain: union_domain.domain)
  end

end
