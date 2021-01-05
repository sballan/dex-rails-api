web:  bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
worker: sidekiq --environment $RAILS_ENV
worker_nofetch: sidekiq -q cache,64 -q rank,8 -q index,4 --environment $RAILS_ENV