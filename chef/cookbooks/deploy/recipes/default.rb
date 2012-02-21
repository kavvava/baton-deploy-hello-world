# Chef attributes defined by baton are
#
# * node.deploy.target_dir - the full directory name the artiball is extracted too
#                            eg - /srv/baton-deploy-hello-world/releases/<sha>
#
# * node.deploy.base_dir - the home directory - eg /srv/baton-deploy-hello-world
# * node.deploy.project - the name of the project - eg baton-deploy-hello-world
# * node.deploy.user - the username that the deployment will run as - eg baton-deploy-hello-world

target_dir = node.deploy.target_dir
base_dir = node.deploy.base_dir
project = node.deploy.project
user = node.deploy.user

# we have a fairly similar directory structure to the one used by capistrano. 
# Items such as configuration that need to be present in the target directory for the app to run
# should be placed in the ``shared`` directory and symlinked into place during chef's run.

shared_dir = ::File.join(base_dir, "shared")

# For a sessions directory ``tmp/sessions`` placed in the root of the application, 
# place the directory in ``shared/tmp/sessions``, then symlink ``shared/tmp/sessions`` to ``target_dir/tmp/sessions``

sd = ::File.join(shared_dir, "tmp/sessions")
td = ::File.join(target_dir, "tmp/sessions")

# ensure that the source directory exists, even if it's empty

directory sd do
  owner user
  recursive true
end

# remove the target directory, so we can always symlink to it

directory td do
  recursive true
  action :delete
end

# Create the symlink
link td do
  to sd
end

# For a single config file, ``config/config.yml``, follow much the same procedure
file ::File.join(target_dir,"config/config.yml") do
  action :delete
end

link ::File.join(target_dir,"config/config.yml") do
  to ::File.join(shared_dir,"config/config.yml")
end

# generate a Procfile with correct paths
template ::File.join(base_dir, "Procfile") do
  source "Procfile.erb"
  owner user
  mode "0644"
end

# Use a rbenv-version file to specify the required version of ruby
rbenv_local ::File.join(target_dir, ".rbenv-version") do
  user user
end

# Use foreman to generate upstart jobs from the Procfile
foreman project do
  dir target_dir
  user user
end


