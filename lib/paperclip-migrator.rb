require "clamp"
require "progressbar"
require "highline"
require "thor"
require "paperclip"
require "colored"
require 'active_record'

module Paperclip
  module Migrator
    autoload :AttachmentInstance, 'paperclip-migrator/attachment_instance'
    autoload :Command, 'paperclip-migrator/command'
    autoload :PaperclipMover, 'paperclip-migrator/paperclip_mover'
    autoload :VERSION, 'paperclip-migrator/version'
  end
end
