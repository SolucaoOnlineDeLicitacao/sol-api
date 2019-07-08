require File.expand_path('../environment', __FILE__)

# Cooperative API Integration
coop_cron_syntax_frequency = ::Integration::Cooperative::Configuration.first_or_initialize.schedule
if coop_cron_syntax_frequency.present?
  every coop_cron_syntax_frequency do
    runner "Import::CooperativeWorker.perform_async"
  end
end

# Covenant API Integration
covenant_cron_syntax_frequency = ::Integration::Covenant::Configuration.first_or_initialize.schedule
if covenant_cron_syntax_frequency.present?
  every covenant_cron_syntax_frequency do
    runner "Import::CovenantWorker.perform_async"
  end
end

# Item API Integration
item_cron_syntax_frequency = ::Integration::Item::Configuration.first_or_initialize.schedule
if item_cron_syntax_frequency.present?
  every item_cron_syntax_frequency do
    runner "Import::ItemWorker.perform_async"
  end
end

# Refuse old contracts
every 30.minutes, roles: [:app] do
  runner "Contract::SystemRefuseWorker.perform_async"
end

# Status changes
every 1.day, at: '08:00 am', roles: [:app] do
  runner "Bidding::ApprovedToOngoingWorker.perform_async"
end

every 1.day, at: '12:00 pm', roles: [:app] do
  runner "Bidding::OngoingToUnderReviewWorker.perform_async"
  runner "Bidding::DrawToUnderReviewWorker.perform_async"
end
