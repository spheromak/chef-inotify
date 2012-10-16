#
#
class Chef
  class Client

   def run_ohai
      Chef::Log.debug "Inotify journal: #{Chef::Inotify.journal}"
      Chef::Inotify.process
      ohai.all_plugins
    end 

  end
end
