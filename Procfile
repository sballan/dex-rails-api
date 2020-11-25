web:  bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
worker: sidekiq --environment $RAILS_ENV
worker2: sidekiq --environment $RAILS_ENV