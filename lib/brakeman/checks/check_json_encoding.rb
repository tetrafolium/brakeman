require 'brakeman/checks/base_check'

class Brakeman::CheckJSONEncoding < Brakeman::BaseCheck
  Brakeman::Checks.add self

  @description = "Checks for missing JSON encoding (CVE-2015-3226)"

  def run_check
    if (version_between? "4.1.0", "4.1.10" or version_between? "4.2.0", "4.2.1") and !has_workaround?
      message = msg(msg_version(rails_version), " does not encode JSON keys ", msg_cve("CVE-2015-3226"), ". Upgrade to ")

      message << if version_between? "4.1.0", "4.1.10"
        msg_version("4.1.11")
      else
        msg_version("4.2.2")
                 end

      confidence = if tracker.find_call(:methods => %i[to_json encode]).any?
        :high
      else
        :medium
                   end

      warn :warning_type => "Cross-Site Scripting",
        :warning_code => :CVE_2015_3226,
        :message => message,
        :confidence => confidence,
        :gem_info => gemfile_or_environment,
        :link_path => "https://groups.google.com/d/msg/rubyonrails-security/7VlB_pck3hU/3QZrGIaQW6cJ"
    end
  end

  def has_workaround?
    workaround = s(:module, :ActiveSupport,
                   s(:module, :JSON,
                     s(:module, :Encoding,
                       s(:call, nil, :private),
                       s(:class, :EscapedString, nil,
                         s(:defn, :to_s,
                           s(:args),
                           s(:self))))))

    tracker.initializers.any? do |_name, initializer|
      initializer == workaround
    end
  end
end
