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
      }.to raise_error(RuntimeError, "Invalid config - Missing values for service-backup.blobstore.bucket_name, service-backup.blobstore.bucket_path.\n#{custom_msg}")
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
      }.to raise_error(RuntimeError, "Invalid config - Missing values for service-backup.scp.user.\n#{custom_msg}")
    end
  end

  context 'when the manifest contains no backup properties' do
    let(:manifest) { YAML.load_file('spec/fixtures/skip_backups.yml') }

    it 'templates without error' do
      renderer.render('jobs/service-backup/templates/ctl.erb')
    end
  end
end
