# frozen_string_literal: true

require "active_record"
require "yaml"
require "erb"

require_relative "snomed_model/version"
require_relative "snomed_model/concept"

module SnomedModel
  class Error < StandardError; end
  # Your code goes here...
end

file = File.expand_path("./db/config.yml")
config = YAML.load_file(file, aliases: true)
env = config[ENV["SNOMED_ENV"] || "development"]

ActiveRecord::Base.establish_connection(
  adapter:  env["adapter"],
  database: ERB.new(env["database"]).result,
  username: ERB.new(env["username"]).result,
  password: ERB.new(env["password"]).result,
  host:     ERB.new(env["host"]).result
)
