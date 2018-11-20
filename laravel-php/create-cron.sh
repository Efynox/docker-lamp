#!/bin/sh

# Execute artisan schedule every minutes
crontab -l | { cat; echo '*	*	*	*	*	cd /app && php artisan schedule:run >> /tmp/artisan_`date +\%d_\%m_\%Y`.log 2>&1'; } | crontab -

# Cleaning log every saturday at 00:05
crontab -l | { cat; echo '5	0	*	*	6	rm /tmp/artisan_`date -d yesterday +\%d_\%m_\%Y`.log'; } | crontab -

crond 
