# chef-inotify cookbook
A Proof of concept cookbook that implements inotify awareness in chef file/template/cookbook_file resources


# Requirements
* This was proofed chef-client version  _10.14.2_  I don't think it will work on anything prior
* Client has to be linux (other os's have similar functionality, but this proof is only for Inotify)
* Need to install the _rb-inotify_ gem on the client

# Usage
add this cookbook to your run_list, and it should start emitting a heap of info messages and hook the file/template/cookbook_file resources to inotify

# Recipes
default:  just makes sure the libs get loaded


# Author

Author:: Jesse Nelson (<spheromak@gmail.com>)
# License

Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

