ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-bookworm-slim

#=======================================================================================================================
# PERMISSIONS
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

#=======================================================================================================================
# SYSTEM UPDATE
RUN apt-get update && apt-get upgrade -y

#=======================================================================================================================
# DIRECTORY SETUP
WORKDIR /var/www/html/portal

#=======================================================================================================================
# ADDITIONAL PROJECT SPECIFIC STEPS
# here goes anything that is not covered by the above steps

#=======================================================================================================================
USER node
