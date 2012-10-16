#
# Add hooks for using the inotify subsys
#

class Chef
  class Provider
    class File  

      def load_current_resource
        Chef::Inotify.watch(@new_resource.path)

        @current_resource = Chef::Resource::File.new(@new_resource.name)
        @new_resource.path.gsub!(/\\/, "/") # for Windows
        @current_resource.path(@new_resource.path)
        if @new_resource.content && ::File.exist?(@new_resource.path)
          @current_resource.checksum(checksum(@new_resource.path))
        end
        setup_acl 
      end


      def action_create
        # this checks if inotify has recieved events and just poops out if not.
        return unless Chef::Inotify.check @new_resource.path


        if !::File.exists?(@new_resource.path)
          description = []
          desc = "create new file #{@new_resource.path}"
          desc << " with content checksum #{short_cksum(new_resource_content_checksum)}" if new_resource.content
          description << desc
          description << diff_current_from_content(@new_resource.content)
          converge_by(description) do
            ::File.open(@new_resource.path, "w+") {|f| f.write @new_resource.content }
            access_controls.set_all
            Chef::Log.info("#{@new_resource} created file #{@new_resource.path}")
          end
        else
          set_content unless @new_resource.content.nil?
          set_all_access_controls
        end
      end


    
    end
  end
end
