class Chef
  class Provider
    class CookbookFile

      def load_current_resource
        Chef::Inotify.watch(@new_resource.path)

        @current_resource = Chef::Resource::CookbookFile.new(@new_resource.name)
        @new_resource.path.gsub!(/\\/, "/") # for Windows
        @current_resource.path(@new_resource.path)
        setup_acl
        @current_resource
      end

      def action_create
        # this checks if inotify has recieved events and just poops out if not.
        return unless Chef::Inotify.check @new_resource.path

        if file_cache_location && content_stale?
          description = []
          description << "create a new cookbook_file #{@new_resource.path}"
          description << diff_current(file_cache_location)
          converge_by(description) do
            Chef::Log.debug("#{@new_resource} has new contents")
            backup_new_resource
            deploy_tempfile do |tempfile|
              Chef::Log.debug("#{@new_resource} staging #{file_cache_location} to #{tempfile.path}")
              tempfile.close
              FileUtils.cp(file_cache_location, tempfile.path)
            end
            Chef::Log.info("#{@new_resource} created file #{@new_resource.path}")
          end
        else
          set_all_access_controls
        end
      end

    end
  end
end
