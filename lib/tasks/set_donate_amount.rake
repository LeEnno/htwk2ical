desc 'Sets current donation amount'
task :set_donate_amount, [:amount] => :environment do |t, args|
  SubjectCache.find_or_create_by_key('donate_amount').update_attributes(:value => args.amount)
  puts "donation amount updated to #{args.amount}"
end