class Chef
  class Provider
    class Template < Chef::Provider::File

      def load_current_resource
        Chef::Inotify.watch @new_resource.path
        super 
        @current_resource.checksum(checksum(@current_resource.path)) if ::File.exist?(@current_resource.path)
      end

      def action_create
        # this checks if inotify has recieved events and just poops out if not.
        return unless Chef::Inotify.check @new_resource.path

        render_with_context(template_location) do |rendered_template|
          rendered(rendered_template)
          update = ::File.exist?(@new_resource.path)
          if update && content_matches?
            Chef::Log.debug("#{@new_resource} content has not changed.")
            set_all_access_controls
          else
            description = []
            action_message = update ? "update #{@current_resource} from #{short_cksum(@current_resource.checksum)} to #{short_cksum(@new_resource.checksum)}" :
                "create #{@new_resource}"
            description << action_message
            description << diff_current(rendered_template.path)
            converge_by(description) do
              backup
              FileUtils.mv(rendered_template.path, @new_resource.path)
              Chef::Log.info("#{@new_resource} updated content")
              access_controls.set_all!
            end
          end
        end
      end

    end
  end
end
