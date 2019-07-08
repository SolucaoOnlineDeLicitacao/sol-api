module Abilities::Admin
  class Base

    def as_json
      mapped_rules.inject({}) { |hash, rule| hash = map_actions(rule, hash) }
    end

    private

    def exist_integration?
      Integration::Configuration.integrated?
    end

    def mapped_rules
      rules.map { |rule| map_rule(rule) }
    end

    def map_rule(rule)
      {
        actions: rule.actions,
        subject: rule.subjects.map(&:to_s)
      }
    end

    def map_actions(rule, hash)
      rule[:actions].map do |action|
        hash[action] = Array.wrap(hash[action])
        hash[action] << rule[:subject]
        hash[action].flatten!
      end

      hash
    end

  end
end
