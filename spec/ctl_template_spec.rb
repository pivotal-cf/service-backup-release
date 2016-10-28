require 'spec_helper'

RSpec.describe 'Service Backups Ctl script' do
  let(:renderer) do
    Bosh::Template::Renderer.new(
      context: BoshEmulator.director_merge(
        YAML.load_file(manifest_file.path), 'service-backup'
      ).to_json
    )
  end
  let(:rendered_template) { renderer.render('jobs/service-backup/templates/ctl.erb') }

  after(:each) { manifest_file.close }

  context 'when the manifest contains a custom backup user' do
    let(:manifest_file) { File.open('spec/fixtures/valid_with_backup_user.yml') }

    it 'templates the value of backup_user' do
      expect(rendered_template).to include("backup_user='backuper'")
    end
  end

  context 'when the manifest does not specify a custom backup user' do
    let(:manifest_file) { File.open('spec/fixtures/valid_s3.yml') }

    it 'templates the default value' do
      expect(rendered_template).to include("backup_user='vcap'")
    end
  end

  context 'when the manifest specifies a source folder' do
    let(:manifest_file) { File.open('spec/fixtures/valid_s3.yml') }

    it 'templates the value of source folder' do
      expect(rendered_template).to include("source_folder='/foo'")
    end
  end
end
