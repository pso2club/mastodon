# frozen_string_literal: true

class UnionDomainWorker
  include Sidekiq::Worker

  def perform(union_domain_id)
    UnionDomainService.new.call(UnionDomain.find(union_domain_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
