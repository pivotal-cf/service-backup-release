require 'spec_helper'

require 'yaml'
require 'bosh/template/renderer'
require 'bosh/template/property_helper'

RSpec.describe 'backup job template rendering' do
  let(:renderer) {
     Bosh::Template::Renderer.new({context: emulate_bosh_director_merge(YAML.load_file(manifest_file)).to_json})
  }
  let(:custom_msg) { 'custom message' }

  context 'when the manifest contains valid s3 properties' do
    let(:manifest_file) { 'spec/fixtures/valid_s3.yml' }

    it 'templates without error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end
  end

  context 'when the manifest contains invalid S3 properties' do
    let(:manifest_file) { 'spec/fixtures/invalid_s3.yml' }

    it 'raises an error containing a custom message' do
      expect {
        renderer.render('jobs/service-backup/templates/ctl.erb')
      }.to raise_error(RuntimeError, "Invalid config - Missing values for service-backup.destination.s3.bucket_name, service-backup.destination.s3.bucket_path.\n#{custom_msg}")
    end
  end

  context 'when the manifest contains valid scp properties' do
    let(:manifest_file) { 'spec/fixtures/valid_scp.yml' }

    it 'templates without error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end
  end

  context 'when the manifest contains invalid S3 properties' do
    let(:manifest_file) { 'spec/fixtures/invalid_scp.yml' }

    it 'raises an error containing a custom message' do
      expect {
        renderer.render('jobs/service-backup/templates/ctl.erb')
      }.to raise_error(RuntimeError, "Invalid config - Missing values for service-backup.destination.scp.user.\n#{custom_msg}")
    end
  end

  context 'when the manifest contains multiple destination properties' do
    let(:manifest_file) { 'spec/fixtures/invalid_multiple_destinations.yml' }

    it 'raises an error' do
      expect {
        renderer.render('jobs/service-backup/templates/ctl.erb')
      }.to raise_error(RuntimeError, "Invalid config - You can only specify one backup destination in the manifest.")
    end
  end

  context 'when the manifest contains no backup destination properties' do
    let(:manifest_file) { 'spec/fixtures/skip_backups.yml' }

    it 'templates without error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end
  end

  context 'when the manifest contains no backup properties' do
    let(:manifest_file) { 'spec/fixtures/no_service_backups.yml' }

    it 'templates without error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end
  end

  context 'when the manifest contains valid azure properties' do
    let(:manifest_file) { 'spec/fixtures/valid_azure.yml' }

    it 'templates without error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end

    context 'without the optional properties' do
      let(:manifest_file) { 'spec/fixtures/valid_azure_without_optional.yml' }

      it 'templates without error' do
        renderer.render('jobs/service-backup/templates/ctl.erb')
      end
    end
  end

  context 'when the manifest contains invalid azure properties' do
    let(:manifest_file) { 'spec/fixtures/invalid_azure.yml' }

    it 'raises an error containing a custom message' do
      expect {
        renderer.render('jobs/service-backup/templates/ctl.erb')
      }.to raise_error(RuntimeError, "Invalid config - Missing values for service-backup.destination.azure.storage_account, service-backup.destination.azure.container, service-backup.destination.azure.path.\n#{custom_msg}")
    end
  end

  context 'when the manifest contains a service identifier command' do
    let(:manifest_file) { 'spec/fixtures/service_identifier.yml' }

    it 'templates without an error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end

    it 'templates the service identifier cmd option in the control scripts' do
      ctl = renderer.render('jobs/service-backup/templates/ctl.erb')
      expect(ctl).to match("--service-identifier-cmd 'service-identifier-cmd'")
    end

  end


  include Bosh::Template::PropertyHelper

  # Trying to emulate bosh director Bosh::Director::DeploymentPlan::Job#extract_template_properties
  def emulate_bosh_director_merge(manifest)
    manifest_properties = manifest["properties"]

    job_spec = YAML.load_file('jobs/service-backup/spec')
    spec_properties = job_spec["properties"]

    effective_properties = {}
    spec_properties.each_pair do |name, definition|
      copy_property(effective_properties, manifest_properties, name, definition["default"])
    end

    manifest.merge({"properties" => effective_properties})
  end
end
