namespace :premium do
  task load: :environment do 
    Plan.all.each do |plan|
      plan.premium_tables.each do |premium|
        cache_key = [plan.hios_id, plan.active_year, premium.age].join('-')
        $redis.set(cache_key, premium.cost)
      end
    end
  end
end
