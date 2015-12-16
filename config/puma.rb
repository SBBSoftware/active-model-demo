require 'puma'
# Change to match your CPU core count
workers 2

# Min and Max threads per worker
threads 1, 6
# for mina
puts "The file is #{__FILE__}"
app_dir = File.expand_path("../../../", __FILE__)
t = File.expand_path("../../../../", __FILE__)
puma_dir = "#{t}/puma"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

# Set up socket location
socket_location = "unix://#{puma_dir}/sockets/sockets.sbb.sock"
bind socket_location
puts '-------------------------'
puts 'settings'
puts "App dir #{app_dir}"
puts "Shared dir #{t}"

puts "Puma dir #{puma_dir}"
puts "Binding to socket #{socket_location}"
puts '-------------------------'
puts 'listening'
# Logging

stdout_redirect "#{puma_dir}/log/puma.stdout.log", "#{puma_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{puma_dir}/pids/puma.pid"
state_path "#{puma_dir}/pids/puma.state"
activate_control_app

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
