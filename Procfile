web:  bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
worker: sidekiq --environment $RAILS_ENV
worker_nolock: sidekiq -q rank -q index -q crawl --environment $RAILS_ENV