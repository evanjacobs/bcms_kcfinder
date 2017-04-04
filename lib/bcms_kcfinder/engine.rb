require 'browsercms'
require 'jquery-migrate-rails'

module BcmsKcfinder
  class Engine < ::Rails::Engine
    isolate_namespace BcmsKcfinder
    include Cms::Module


    config.to_prepare do
      Cms::Section.send(:include, BcmsKcfinder::FinderExtension)
      Cms::Attachment.send(:include, BcmsKcfinder::Attachment::Linkable)
      Cms::Page.send(:include, BcmsKcfinder::Page::Linkable)
      Rse::ImageBlock.send(:include, BcmsKcfinder::Image::Linkable)

    end

    initializer 'bcms_kcfinder.enable' do |app|
       app.config.cms.ckeditor.configuration_file = "bcms_kcfinder/config"
    end
  end
end

# Decorate core CMS classes so they all response to same methods for generating JSON API.
module BcmsKcfinder
  module Page
    module Linkable
      def link_to_path
        path
      end

      def size_in_bytes
        0
      end
    end
  end
  module Image
    module Linkable
      def link_to_path
        path
      end

      def size_in_bytes
        file.size
      end
    end
  end
  module Attachment
    module Linkable
      def name
        self.data_file_name
      end

      def size_in_bytes
        data_file_size
      end

      def link_to_path
        url
      end

    end
  end
  module FinderExtension
    LINKABLE_TYPES = ["Cms::Page", "Cms::Attachment"]

    def linkable_children
      ancestry = self.node.children.first.ancestry
      pages = Cms::Page.find_by_sql("SELECT * from cms_section_nodes n, cms_pages p where n.ancestry = '#{ancestry}' and n.node_type = 'Cms::Page' and p.id = n.node_id and p.deleted=false;")
      attachments = Cms::Attachment.find_by_sql("SELECT * from cms_section_nodes n, cms_attachments p where n.ancestry = '#{ancestry}' and n.node_type = 'Cms::Attachment' and p.id = n.node_id and p.deleted=false;")
      (pages + attachments).compact
    end
  end
end
