# encoding: utf-8
require "logstash/errors"

module LogStash module BootstrapCheck
  class DefaultConfig
    def self.check(settings)
      # currently none of the checks applies if there are multiple pipelines
      return if settings.get("pipelines").any?

      if settings.get("config.string").nil? && settings.get("path.config").nil?
        raise LogStash::BootstrapCheckError, I18n.t("logstash.runner.missing-configuration")
      end

      if settings.get("config.string") && settings.get("path.config")
        raise LogStash::BootstrapCheckError, I18n.t("logstash.runner.config-string-path-exclusive")
      end

      if settings.get("config.reload.automatic") && settings.get("path.config").nil?
        raise LogStash::BootstrapCheckError, I18n.t("logstash.runner.reload-without-config-path")
      end
    end
  end
end end
