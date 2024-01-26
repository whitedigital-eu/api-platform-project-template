FROM nginx:mainline-bookworm

#=======================================================================================================================
# SYSTEM UPDATE
RUN apt-get update && apt-get upgrade -y

#=======================================================================================================================
# DIRECTORY SETUP
# remove default nginx config (it should be supplied via a bind mount)
RUN rm -rf /etc/nginx/conf.d/*
# set ownership of needed resources to nginx user (cache/log/conf dirs and pid file)
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /var/run/nginx.pid
WORKDIR /var/www/html

#=======================================================================================================================
USER nginx