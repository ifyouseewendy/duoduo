# encoding: utf-8

require 'spec_helper'

describe CarrierWave::Uploader, filemagic: true do

  before do
    @uploader_class = Class.new(CarrierWave::Uploader::Base) do
      include CarrierWave::Uploader::MagicMimeWhitelist

      # Accepts only images
      def whitelist_mime_type_pattern
        /image\//
      end
    end

    @uploader = @uploader_class.new
  end

  after do
    FileUtils.rm_rf(public_path)
  end

  describe '#cache!' do

    before do
      allow(CarrierWave).to receive(:generate_cache_id).and_return('1369894322-345-2255')
    end

    context "when the is no whitelist pattern" do
      before do
        allow(@uploader).to receive(:whitelist_mime_type_pattern).and_return(nil)
      end

      it "does not raise an integrity error" do
        expect {
          @uploader.cache!(File.open(file_path('ruby.gif')))
        }.not_to raise_error
      end
    end

    context "when there is a whitelist pattern" do
      context "and the file has compliant content-type" do
        it "does not raise an integrity error" do
          expect {
            @uploader.cache!(File.open(file_path('ruby.gif')))
          }.not_to raise_error
        end
      end

      context "and the file has not compliant content-type" do
        it "raises an integrity error" do
          expect {
            @uploader.cache!(File.open(file_path('bork.txt')))
          }.to raise_error
        end
      end
    end
  end
end
