# for dependencies:
#   task :some_task => :some_task_to_execute_before do ...
#
# for multiple tasks:
#   task :batch_task => [:task_1, :task_2, :task_3]

desc 'Pings PING_URL to keep a dyno alive'
task :dyno_ping do
  require 'net/http'

  if ENV['PING_URL']
    uri = URI(ENV['PING_URL'])
    Net::HTTP.get_response(uri)
  end
end