require 'puma'
# Change to match your CPU core count
workers 2

# Min and Max threads per worker
threads 1, 6
# for mina
app_dir = File.expand_path("../../../../", __FILE__)
shared_dir = "#{app_dir}/puma"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

# Set up socket location
socket_location = "unix://#{shared_dir}/sockets/sockets.sbb.sock"
bind socket_location
puts '-------------------------'
puts 'Enviornment settings'
puts "App dir #{app_dir}"
puts "Shared dir #{shared_dir}"
puts "Binding to socket #{socket_location}"
puts '-------------------------'
puts 'listening'
# Logging

stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
