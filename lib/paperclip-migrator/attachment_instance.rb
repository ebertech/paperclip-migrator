module Paperclip
  module Migrator
    class AttachmentInstance
      def initialize(instance, klass, attachment, old_layout, dry_run = true)
        @dry_run = dry_run
        @instance = instance
        @klass = klass
        @attachment = attachment
        @old_layout = old_layout
        @old_path = @instance.send(@attachment).send(:interpolate, @old_layout)
      end

      def migrate!
        if File.exists?(@old_path)
          if @dry_run
            puts "Would be loading it from #{@old_path}".green
          else
            begin
              @instance.send(:"#{@attachment}=", File.open(@old_path))
              @instance.save!
            rescue
              raise "#{@klass.name} (##{@instance.id}) got an exception when saving #{@attachment} using #{@old_path}: #{$!}"
            end
          end
        else
          raise "#{@klass.name} (##{@instance.id}) can't find picture for #{@attachment} using #{@old_path}"
        end
      end
    end
  end
end