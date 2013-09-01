desc 'Updates schedule for all subjects'
task :rebuild_cache => :environment do
  Subject.rebuild_cache
end