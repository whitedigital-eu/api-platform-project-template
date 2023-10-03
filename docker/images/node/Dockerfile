FROM node:18-bookworm-slim

ARG HOST_UID
ARG HOST_GID

# set host UID to node user
RUN username=$(echo $(getent passwd $HOST_UID | cut -d: -f1)) \
    && if [[ $username != '' ]] && [[ $username != 'node' ]]; then \
      userdel $username; \
    fi \
    && usermod -u $HOST_UID node

# set host HOST GID to node group
RUN groupname=$(echo $(getent group $HOST_GID | cut -d: -f1)) \
    && if [[ $groupname != '' ]] && [[ $groupname != 'node' ]]; then \
      groupdel $groupname; \
    fi \
    && groupmod -g $HOST_GID node

# update system and install tools
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends vim

# set default working dir
WORKDIR /var/www/html/portal

# set default user
USER node
