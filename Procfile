web:  bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
worker: sidekiq --environment $RAILS_ENV
worker_nofetch: sidekiq -q rank -q index -q crawl -q cache --environment $RAILS_ENV