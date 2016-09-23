require 'rspec'
require 'rspec/its'
require 'bosh/template/property_helper'
require 'bosh/template/renderer'
require 'yaml'

ROOT = File.expand_path('..', __dir__)

class BoshEmulator
  extend ::Bosh::Template::PropertyHelper

  def self.director_merge(manifest, job_name)
    manifest_properties = manifest['properties']

    job_spec = YAML.load_file("jobs/#{job_name}/spec")
    spec_properties = job_spec['properties']

    effective_properties = {}
    spec_properties.each_pair do |name, definition|
      copy_property(effective_properties, manifest_properties, name, definition['default'])
    end

    manifest.merge({'properties' => effective_properties})
  end
end

RSpec.configure do |c|
  c.disable_monkey_patching!
  c.color = true
  c.full_backtrace = true
  c.order = 'random'
end
