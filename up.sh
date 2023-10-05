#!/usr/bin/env bash

ENVIRO=${1:-1}
FRESH=${2:-1}

ENVIROS=("dev" "stage" "prod")

export KEY="change_me"
NAME="${KEY}_${ENVIRO}"

if [[ ! " ${ENVIROS[*]} " =~ ${ENVIRO} ]]; then
    echo "Allowed environments are: dev, stage, prod"
    exit
fi

PROFILE=dev

if [ -f ./.env ]; then
    source ./.env
fi

# TODO: uncomment if enabling ssl via letsencrypt
#if [[ "$ENVIRO" != "dev" ]]; then
#    cd docker/"$ENVIRO"/certbot || exit
#    running=$(docker container inspect -f '{{.State.Status}}' "${NAME}_nginx" 2> /dev/null | xargs)
#    if [[ "$FRESH" == "fresh" ]] && [[ "$running" != "running" ]]; then
#        docker compose -f docker-compose.with_port.yml up
#    else
#        docker compose -f docker-compose.yml up
#    fi
#    cd ../ || exit
#else
    cd docker/"$ENVIRO" || exit
#fi

export HOST_UID=`id -u`
export HOST_GID=`id -g`

if [[ "${PROFILE}" != "traefik" ]]; then
    docker kill $(docker ps -q) # stop all existing runner containers from previous projects
fi

if [[ "$FRESH" == "rebuild" ]] || [[ "$FRESH" == "fresh" ]]; then
    docker compose down 2>&1
    docker compose rm -s -f 2>&1
    docker compose build --no-cache --pull || exit
fi

docker compose up -d --force-recreate --pull --build --remove-orphans

docker image prune --force

source .env

cd ../../src/portal || exit

if [[ "$FRESH" == "fresh" ]]; then
    echo "VITE_API_BASE_URL=https://${DOMAIN}" >> public/.env
fi

cd ../../src/api || exit

ENV_FILE=.env.local
ENV_FILE_TEST=.env.test.local

if [[ "$FRESH" == "fresh" ]]; then
    if [ ! -f "./$ENV_FILE" ]; then
        cp "../../.env.local.dist"  ${ENV_FILE}
        if [[ "$ENVIRO" != "dev" ]]; then
            sed -i '$d' ${ENV_FILE}
        fi
        echo "APP_ENV=$ENVIRO" >> ${ENV_FILE}
        if [[ "$ENVIRO" != "dev" ]]; then
            echo "APP_DEBUG=false" >> ${ENV_FILE}
        else
            echo "APP_DEBUG=true" >> ${ENV_FILE}
        fi
        sed -i'' -e "s/_dev_/_${ENVIRO}_/g" ${ENV_FILE}

        echo "CORS_ALLOW_ORIGIN=[\"https://${ADMIN}\"]" >> ${ENV_FILE}
    fi

    if [ ! -f "./$ENV_FILE_TEST" ]; then
        cp "../../.env.test.local.dist" ${ENV_FILE_TEST}
        sed -i'' -e "s/_dev_/_${ENVIRO}_/g" ${ENV_FILE_TEST}
    fi

    files=("var" "var/cache" "var/cache/dev" "var/cache/prod" "var/cache/stage" "vendor" "public/bundles" "public/bundles/apiplatform" "public/storage" "public/storage/uploads")

    for i in "${files[@]}"; do
        if [[ ! -d $i ]]; then
            mkdir -m 0777 "$i"
        fi

        set -- "$(stat --format '%a' "$i")"
        if [[ ! $2 == 777 ]]; then
            chmod -R 777 "$i"
        fi
    done
fi

docker exec "${NAME}_php" rm -rf var/cache/*
docker exec "${NAME}_php" bash -c 'git config --global --add safe.directory "*"'

if [[ "$FRESH" == "fresh" ]]; then
    docker exec "${NAME}_php" composer install -n --no-scripts
    docker exec "${NAME}_php" bin/console doctrine:database:drop --force 2>&1
    docker exec "${NAME}_php" bin/console doctrine:database:create
fi

if [[ "$ENVIRO" == "dev" ]] || [[ "$FRESH" == "fresh" ]]; then
    docker exec "${NAME}_php" composer install -n
else
    docker exec "${NAME}_php" composer install -n --no-dev
fi

if [[ "$FRESH" == "fresh" ]]; then
    docker exec "${NAME}_php" bin/console doctrine:migrations:migrate -n
    if [[ "$ENVIRO" == "dev" ]]; then
        docker exec "${NAME}_php" bin/console doctrine:fixtures:load -n
    else
        docker exec "${NAME}_php" bash -c "APP_ENV=dev bin/console doctrine:fixtures:load -n --group=user"
        docker exec "${NAME}_php" composer install -n --no-dev
    fi
fi

if [[ "$ENVIRO" != "dev" ]]; then
    docker exec "${NAME}_node" bash -c "yarn --prod && yarn build"
    docker exec "${NAME}_node" bash -c "cd common && yarn export-translations"
    docker rm -f "${NAME}_node"
    docker exec "${NAME}_php" bin/console wd:translation:import lv translations.json
    docker exec "${NAME}_php" bin/console wd:translation:import en translations.json
fi

cd ../.. || exit
