require 'spec_helper'

require 'yaml'
require 'bosh/template/renderer'

RSpec.describe 'backup job template rendering' do
  let(:renderer) { Bosh::Template::Renderer.new({context: manifest.to_json}) }
  let(:custom_msg) { 'custom message' }

  context 'when the manifest contains valid s3 properties' do
    let(:manifest) { YAML.load_file('spec/fixtures/valid_s3.yml') }

    it 'templates without error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end
  end

  context 'when the manifest contains invalid S3 properties' do
    let(:manifest) { YAML.load_file('spec/fixtures/invalid_s3.yml') }

    it 'raises an error containing a custom message' do
      expect {
        renderer.render('jobs/service-backup/templates/ctl.erb')
      }.to raise_error(RuntimeError, "Invalid config - Missing values for service-backup.destination.s3.bucket_name, service-backup.destination.s3.bucket_path.\n#{custom_msg}")
    end
  end

  context 'when the manifest contains valid scp properties' do
    let(:manifest) { YAML.load_file('spec/fixtures/valid_scp.yml') }

    it 'templates without error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end
  end

  context 'when the manifest contains invalid S3 properties' do
    let(:manifest) { YAML.load_file('spec/fixtures/invalid_scp.yml') }

    it 'raises an error containing a custom message' do
      expect {
        renderer.render('jobs/service-backup/templates/ctl.erb')
      }.to raise_error(RuntimeError, "Invalid config - Missing values for service-backup.destination.scp.user.\n#{custom_msg}")
    end
  end

  context 'when the manifest contains multiple destination properties' do
    let(:manifest) { YAML.load_file('spec/fixtures/invalid_multiple_destinations.yml') }

    it 'raises an error' do
      expect {
        renderer.render('jobs/service-backup/templates/ctl.erb')
      }.to raise_error(RuntimeError, "Invalid config - You can only specify one backup destination in the manifest.")
    end
  end

  context 'when the manifest contains no backup properties' do
    let(:manifest) { YAML.load_file('spec/fixtures/skip_backups.yml') }

    it 'templates without error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end
  end
  context 'when the manifest contains no destination key' do
    let(:manifest) { YAML.load_file('spec/fixtures/skip_backups_without_destination_key.yml') }

    it 'templates without error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end
  end
end
