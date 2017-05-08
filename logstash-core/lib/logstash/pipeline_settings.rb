# encoding: utf-8
require "logstash/settings"

module LogStash
  class PipelineSettings < Settings

    # there are settings that the pipeline uses and can be changed per pipeline instance
    SETTINGS_WHITE_LIST = [
      "pipeline.id", "pipeline.system", "pipeline.reloadable",
      "pipeline.workers", "pipeline.output.workers",
      "pipeline.batch.size", "pipeline.batch.delay",
      "config.string", "path.config", "metric.collect", "config.debug",
      "queue.max_events", "queue.checkpoint.acks", "queue.checkpoint.writes", "queue.checkpoint.interval",
      "queue.type", "queue.page_capacity", "queue.max_bytes", "path.queue", "queue.drain",
      "config.reload.automatic", "config.reload.interval"
    ]

    # register a set of settings that is used as the default set of pipelines settings
    def self.from_settings(settings)
      pipeline_settings = self.new
      SETTINGS_WHITE_LIST.each do |setting|
        pipeline_settings.register(settings.get_setting(setting).clone)
      end
      pipeline_settings
    end

    def register(setting)
      unless SETTINGS_WHITE_LIST.include?(setting.name)
        raise ArgumentError.new("Only pipeline related settings can be registed in a PipelineSettings object. Received \"#{setting.name}\". Allowed settings: #{SETTINGS_WHITE_LIST}")
      end
      super(setting)
    end
  end
end
