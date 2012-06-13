module Paperclip
  module Migrator
    class Command < Clamp::Command
      option ["-q", "--quiet"], :flag, "suppress output", :default => false
      option ["-p", "--progress-bar"], :flag, "show a progress bar", :default => false
      option ["-d", "--dry-run"], :flag, "dry run, don't actually do antying", :default => true

      def execute
        warn "This is a dry run, no changes will be made to the actual files." if dry_run?
        begin
          request_class.tap do |klass|
            request_attachment(klass).tap do |attachment|
              request_old_layout(klass, attachment).tap do |old_layout|
                with_progress_bar(klass, attachment) do |progress_bar|
                  PaperclipMover.new(klass, attachment, old_layout, dry_run?).each_attachment do |attachment_instance|
                    begin
                      attachment_instance.migrate!
                    rescue
                      complain($!)
                    end
                    progress_bar.try(:inc)
                  end
                end
              end
            end
          end
        rescue Interrupt
          error "Control-C, Quitting"
        rescue
          error $!
        end
      end

      private

      def error(message)
        puts message.to_s.red unless quiet?
        exit 1
      end

      def complain(message)
        puts message.to_s.red unless quiet?
      end

      def warn(message)
        puts message.to_s.yellow unless quiet?
      end

      def say(message)
        puts message.green unless quiet?
      end

      def request_class
        PaperclipMover.candidate_classes.tap do |classes|
          raise "No classes have paperclips" if classes.empty?
          HighLine.new.choose do |menu|
            menu.prompt = "Please choose your class:  "
            classes.each do |klass|
              menu.choice(klass.name) { return klass }
            end
          end
        end
      end

      def request_attachment(klass)
        attachments = PaperclipMover.attachment_keys_for(klass)

        if attachments.size == 1
          say "Using #{attachments.first} (it's the only one)"
          return attachments.first
        else
          HighLine.new.choose do |menu|
            menu.prompt = "Please choose your attachment:  "
            attachments.each do |attachment|
              menu.choice(attachment.to_s) { return attachment.to_sym }
            end
          end
        end
      end

      def request_old_layout(klass, attachment)
        auto_detected_layouts = PaperclipMover.auto_detected_layouts_for(klass, attachment)

        HighLine.new.choose do |menu|
          if auto_detected_layouts.empty?
            menu.prompt = "Could not autodetect layout, please select: "
          else
            menu.prompt = "Please select layout: "
          end

          PaperclipMover::DEFAULT_LAYOUTS.each do |layout|
            label = layout
            if auto_detected_layouts.include?(layout)
              label += " (autodetected)"
              label = label.green
            end
            menu.choice(label) { layout }
          end
          menu.choice("Other") do
            HighLine.new.ask("Enter the layout: ") do |q|
              q.validate = PaperclipMover::SANTITY_CHECK
              q.responses[:not_valid] = "That doesn't look like a Paperclip interpolated path."
            end
          end
        end
      end

      def with_progress_bar(klass, attachment)
        if quiet? || !progress_bar?
          yield nil
        else
          ProgressBar.new("#{klass}##{attachment}", klass.count).tap do |pbar|
            yield pbar
            pbar.finish
          end
        end
      end
    end
  end
end