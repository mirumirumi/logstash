# encoding: utf-8
require "logstash/config/source/local"
require "logstash/util/loggable"

module LogStash module Config module Source

  class MultiLocal < Local
    include LogStash::Util::Loggable

    def initialize(settings)
      @original_settings = settings
      super(settings)
    end

    def pipeline_configs
      pipelines = retrieve_yaml_pipelines()
      duplicate_pipeline_ids = detect_duplicate_pipelines(pipelines)
      if duplicate_pipeline_ids.any?
        raise ConfigurationError.new("Pipelines YAML file contains duplicate pipeline ids: #{duplicate_pipeline_ids.inspect}. Location: #{pipelines_yaml_location}")
      else
        pipelines.map do |pipeline_settings|
          @settings = @original_settings.clone.merge(pipeline_settings)
          # this relies on instance variable @settings and the parent class' pipeline_configs
          # method. The alternative is to refactor most of the Local source methods to accept
          # a settings object instead of relying on @settings.
          super # create a PipelineConfig object based on @settings
        end
      end
    end

    def match?
      true
    end

    private
    def retrieve_yaml_pipelines
      result = read_pipelines_yaml()
      case result
      when Array
        result
      when false
        raise ConfigurationError.new("Pipelines YAML file is empty. Path: #{pipelines_yaml_location}")
      else
        raise ConfigurationError.new("Pipelines YAML file must contain an array of pipeline configs. Found \"#{result.class}\" in #{pipelines_yaml_location}")
      end
    end

    def read_pipelines_yaml
      ::YAML.load(IO.read(pipelines_yaml_location()))
    rescue => e
      raise ConfigurationError.new("Failed to read pipelines yaml file. Location: #{pipelines_yaml_location}, Exception: #{e.inspect}")
    end

    def pipelines_yaml_location
      ::File.join(@original_settings.get("path.settings"), "pipelines.yml")
    end

    def detect_duplicate_pipelines(pipelines)
      pipelines.group_by {|pipeline| pipeline["pipeline.id"] }.select {|k, v| v.size > 1 }.map {|k, v| k}
    end
  end
end end end
