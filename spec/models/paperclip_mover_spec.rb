require 'spec_helper'

describe Paperclip::Migrator::PaperclipMover do
  describe "class methods" do
    describe ".candidate_classes" do
      subject { Paperclip::Migrator::PaperclipMover.candidate_classes }
      it "be empty if there are no classes that have paperclips" do
        should be_empty
      end
    end

    describe ".root_dir" do
      context "with Rails defined" do
        before(:each) do
          Rails = double("rails").tap do |double|
            double.stub(:root) { "/some/path" }
          end
        end

        it "should return the current Rails.root" do
          Paperclip::Migrator::PaperclipMover.root_dir.should == Rails.root
        end

        after(:each) do
          Object.instance_eval{remove_const(:Rails)}
        end
      end

      context "without Rails defined" do
        it "should return the current Rails.root" do
          Paperclip::Migrator::PaperclipMover.root_dir.should == Dir.pwd
        end
      end
    end
  end

  it "should raise an exception if we are trying to migrate to the current layout" do
    expect do
      Paperclip::Migrator::PaperclipMover.new(nil, nil, Paperclip::Attachment.default_options[:path])
    end.to raise_exception RuntimeError, "we are already on this layout"
  end
end