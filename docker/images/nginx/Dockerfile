FROM nginx:mainline-bookworm

# update system and install tools
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends vim

# remove default nginx config (it should be supplied via a bind mount)
RUN rm -rf /etc/nginx/conf.d/*

# set ownership of needed resources to nginx user (cache/log/conf dirs and pid file)
RUN touch /var/run/nginx.pid \
    && chown -R nginx:nginx /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /var/run/nginx.pid

# set default working dir
WORKDIR /var/www/html

# set default user
USER nginx