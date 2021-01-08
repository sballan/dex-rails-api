desc 'Application Clock tick'
task :clock_tick do
  ClockJob.perform_later
end