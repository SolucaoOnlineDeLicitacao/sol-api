#
# Validações de sintaxe cron
#
class CronSyntaxValidator < ActiveModel::EachValidator
  REGEX_CRON_SYNTAX = /\A(\*|([0-9]|1[0-9]|2[0-9]|3[0-9]|4[0-9]|5[0-9])|\*\/([0-9]|1[0-9]|2[0-9]|3[0-9]|4[0-9]|5[0-9])) (\*|([0-9]|1[0-9]|2[0-3])|\*\/([0-9]|1[0-9]|2[0-3])) (\*|([1-9]|1[0-9]|2[0-9]|3[0-1])|\*\/([1-9]|1[0-9]|2[0-9]|3[0-1])) (\*|([1-9]|1[0-2])|\*\/([1-9]|1[0-2])) (\*|([0-6])|\*\/([0-6]))\z/

  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || :invalid) unless value.to_s.match? REGEX_CRON_SYNTAX
  end
end
