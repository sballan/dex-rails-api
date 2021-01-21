web:  bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
worker: sidekiq --environment $RAILS_ENV
worker_nofetch: sidekiq -q crawl,2 -q rank,4 -q index,8 -q cache,32 --environment $RAILS_ENV