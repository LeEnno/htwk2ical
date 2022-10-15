desc 'Sets current donation amount'
task :set_donate_amount, [:amount] => :environment do |t, args|
  SubjectCache.find_or_create_by(key: 'donate_amount').update(:value => args.amount)
  puts "donation amount updated to #{args.amount}"
end