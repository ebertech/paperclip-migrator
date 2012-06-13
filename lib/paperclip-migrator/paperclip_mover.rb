module Paperclip
  module Migrator
    class PaperclipMover
      DEFAULT_LAYOUTS = [
        ":rails_root/public/system/:attachment/:id/:style/:filename",
        ":rails_root/public/system/:attachment/:id/:style/:basename.:extension",
        ":rails_root/public/system/:class/:attachment/:id_partition/:style/:basename.:extension",
        ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename",
        Paperclip::Attachment.default_options[:path]
      ].uniq

      SANTITY_CHECK = /(:filename|:basename|:id)/

      class << self
        def auto_detected_layouts_for(klass, attachment)
          [].tap do |auto_detected_layouts|
            possible_attachments_for(klass, attachment).tap do |instances|
              raise "no instances found" if instances.empty?
              instances.each do |inst|
                if inst.send(:"#{attachment}?")
                  DEFAULT_LAYOUTS.detect do |layout|
                    old_file_name = inst.send(attachment).send(:interpolate, layout)
                    if File.exists?(old_file_name)
                      auto_detected_layouts << layout unless auto_detected_layouts.include?(layout)
                    end
                  end
                end
              end
            end
          end
        end

        def root_dir
          if defined?(Rails)
            Rails.root
          else
            Dir.pwd
          end
        end

        def possible_attachments_for(klass, attachment)
          klass.find(:all, :order => "rand()", :limit => 100).select { |inst| inst.send(:"#{attachment}?") }
        end

        def attachment_keys_for(klass)
          klass.attachment_definitions.keys.map(&:to_sym)
        end

        def candidate_classes
          ActiveSupport::Autoload.eager_autoload! if defined?(ActiveSupport::Autoload)
          if ActiveRecord::Base.respond_to?(:descendants)
            ActiveRecord::Base.descendants
          else
            Object.subclasses_of(ActiveRecord::Base)
          end.reject { |c| c.attachment_definitions.nil? }.sort { |a, b| a.name <=> b.name }
        end
      end

      def initialize(klass, attachment, old_layout, dry_run = true)
        if old_layout == Paperclip::Attachment.default_options[:path]
          raise "we are already on this layout"
        end

        @klass = klass
        @attachment = attachment
        @old_layout = old_layout
        @dry_run = dry_run
      end

      def each_attachment
        @klass.all.tap { |collection| raise "No instances found" if collection.empty? }.each do |inst|
          next unless inst.send(:"#{@attachment}?")
          yield AttachmentInstance.new(inst, @klass, @attachment, @old_layout, @dry_run)
        end
      end
    end
  end
end