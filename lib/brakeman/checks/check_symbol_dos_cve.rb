require 'brakeman/checks/base_check'

class Brakeman::CheckSymbolDoSCVE < Brakeman::BaseCheck
  Brakeman::Checks.add self

  @description = "Checks for versions with ActiveRecord symbol denial of service vulnerability"

  def run_check
    fix_version = if version_between?('2.0.0', '2.3.17')
                    '2.3.18'
                  elsif version_between?('3.1.0', '3.1.11')
                    '3.1.12'
                  elsif version_between?('3.2.0', '3.2.12')
                    '3.2.13'
                  end

    if fix_version && active_record_models.any?
      warn :warning_type => "Denial of Service",
        :warning_code => :CVE_2013_1854,
        :message => msg(msg_version(rails_version), " has a denial of service vulnerability in ActiveRecord. Upgrade to ", msg_version(fix_version), " or patch"),
        :confidence => :medium,
        :gem_info => gemfile_or_environment,
        :link => "https://groups.google.com/d/msg/rubyonrails-security/jgJ4cjjS8FE/BGbHRxnDRTIJ"
    end
  end
end
