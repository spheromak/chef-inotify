# Chef::Inotify
#  Simple Inotify Subsystem for Chef File  resources
#
# Copyright (C) 2012 Jesse Nelson <spheromak@gmail.com>
#  
#
class Chef
  class Inotify
    class << self
      require 'rb-inotify'
      require 'chef/log'

      def notifier
        @@notifier ||= INotify::Notifier.new
      end

      def journal
        @@journal ||= Hash.new
      end

      def watch(path)
        begin
          unless journal.has_key? path
            # first time we see it mark add and mark
            Chef::Log.info "Watching new Path #{path}"
            journal[path] = true
            notifier.watch( path, :create,:delete,:modify,:attrib,:moved_to,:moved_from) { |event| journal[path] = true }
          end
        rescue Errno::ENOENT => e
          Chef::Log.info "Marking unseen path for check #{path}"
          # if it doesn't exist make sure it's marked for update
          journal[path] = true
        end
      end


      # if this path is "true" (i.e. has had an event since last process then clear it (set false) and return true
      def check(path)
        Chef::Log.info "Inotify reports #{path} -> #{journal[path]}"
        if journal.has_key? path and journal[path] == true
          clear path
          return true
        end
        false
      end

      def clear(path)
        Chef::Log.info "Clearning Path #{path}"
        journal[path] = false
      end

      def process
        # process blocks till there is an event, in this case jsut wait a lil bit
        # cause the run interval should be giving us enough time
        if IO.select([notifier.to_io], [], [], 0.001)
          notifier.process
        end
      end

   end
  end
end
