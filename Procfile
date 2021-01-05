web:  bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
worker: sidekiq --environment $RAILS_ENV
worker_nofetch: sidekiq -q cache,128 -q rank,8 -q index,4 -q crawl,2 --environment $RAILS_ENV