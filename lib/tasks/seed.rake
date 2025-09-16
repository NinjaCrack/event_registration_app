namespace :custom do
  desc "Seed production database"
  task seed: :environment do
    load Rails.root.join('db', 'seeds.rb')
    puts "Seeds executed successfully!"
  end
end
