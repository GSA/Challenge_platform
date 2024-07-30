#!/bin/bash
echo "------ Starting APP ------ Instance $CF_INSTANCE_INDEX -----"
echo "------ Booting Instance ------ Instance $CF_INSTANCE_INDEX -----"
if [ "$CF_INSTANCE_INDEX" == "0" ]; then
  echo "----- Migrating Database ----- Instance $CF_INSTANCE_INDEX -----"
  bundle exec rake cf:on_first_instance db:migrate
  echo "----- Migrated Database ----- Instance $CF_INSTANCE_INDEX -----"
fi
echo "------ Booting Web Process ------ Instance $CF_INSTANCE_INDEX -----"
bundle exec rails s -b 0.0.0.0 -p $PORT -e $RAILS_ENV
