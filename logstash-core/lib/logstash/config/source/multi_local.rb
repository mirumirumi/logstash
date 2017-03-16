# encoding: utf-8
require "logstash/config/source/local"

module LogStash module Config module Source

  class MultiLocal < Local

    def initialize(settings)
      @original_settings = settings
      super(settings)
    end

    def pipeline_configs
      settings = refresh_yaml_settings
      settings.get("pipelines").map do |pipeline_settings|
				@settings = @original_settings.clone.merge(pipeline_settings)
        # this relies on instance variable @settings and the parent class' pipeline_configs
        # method. The alternative is to refactor most of the Local source methods to accept
        # a settings object instead of relying on @settings.
        super # create a PipelineConfig object based on @settings
      end
    end

    def match?
      multi_pipeline_enabled?
    end

    private
    def refresh_yaml_settings
      @original_settings.from_yaml(@original_settings.get("path.settings"))
    end

    def multi_pipeline_enabled?
      @original_settings.get("pipelines").any?
    end
  end
end end end
