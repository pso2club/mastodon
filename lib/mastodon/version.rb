# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    def major
      2
    end

    def minor
      4
    end

    def patch
      1
    end

    def pre
      nil
    end

    def flags
      '-union'
    end

    def to_a
      [major, minor, patch, pre].compact
    end

    def to_s
      [to_a.join('.'), flags].join
    end

    def source_base_url
      'https://github.com/pso2club/mastodon'
    end

    # specify git tag or commit hash here
    def source_tag
      ['v', to_a.join('.'), flags].join
    end

    def source_url
      if source_tag
        "#{source_base_url}/tree/#{source_tag}"
      else
        source_base_url
      end
    end

    def user_agent
      @user_agent ||= "#{HTTP::Request::USER_AGENT} (Mastodon/#{Version}; +http#{Rails.configuration.x.use_https ? 's' : ''}://#{Rails.configuration.x.web_domain}/)"
    end
  end
end
