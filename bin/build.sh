#!/usr/bin/env bash
#
# Copyright (C) 2021 diva.exchange
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Author/Maintainer: Konrad Bächler <konrad@diva.exchange>
#
# -e  Exit immediately if a simple command exits with a non-zero status
set -e

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/../
cd ${PROJECT_PATH}
PROJECT_PATH=`pwd`

# load helpers
source "${PROJECT_PATH}/bin/util/echos.sh"
source "${PROJECT_PATH}/bin/util/helpers.sh"

# env vars
DIVA_TESTNET=${DIVA_TESTNET:-0}
JOIN_NETWORK=${JOIN_NETWORK:-}
BASE_DOMAIN=${BASE_DOMAIN:-testnet.local}
SIZE_NETWORK=${SIZE_NETWORK:-7}
PURGE=${PURGE:-0}
BASE_IP=${BASE_IP:-172.19.72.}
PORT=${PORT:-17468}
NODE_ENV=${NODE_ENV:-production}
LOG_LEVEL=${LOG_LEVEL:-trace}

# Handle joining
if [[ ${DIVA_TESTNET} > 0 ]]
then
 JOIN_NETWORK=diva.i2p/testnet
 SIZE_NETWORK=1
 BASE_DOMAIN=testnet.diva.i2p
fi

if [[ -n ${JOIN_NETWORK} ]]
then
 SIZE_NETWORK=1
 BASE_DOMAIN=join.${BASE_DOMAIN}
fi

if ! command_exists docker; then
  error "docker not available. Please install it first.";
  exit 1
fi

if ! command_exists docker-compose; then
  error "docker-compose not available. Please install it first.";
  exit 2
fi

PATH_DOMAIN=${PROJECT_PATH}/build/domains/${BASE_DOMAIN}
if [[ ! -d ${PATH_DOMAIN} ]]
then
  mkdir ${PATH_DOMAIN}
  mkdir ${PATH_DOMAIN}/genesis
  mkdir ${PATH_DOMAIN}/keys
  mkdir ${PATH_DOMAIN}/state
  mkdir ${PATH_DOMAIN}/blockstore
fi
cd ${PATH_DOMAIN}

if [[ -f ./diva.yml ]]
then
  if [[ ${PURGE} > 0 ]]
  then
    warn "The confirmation of this action will lead to DATA LOSS!"
    warn "If you want to keep the data, run a backup first."
    confirm "Do you want to DELETE all local data and re-create your environment (y/N)?" || exit 3
    sudo docker-compose --log-level ERROR -f ./diva.yml down --volumes
    rm -rf ${PATH_DOMAIN}/genesis/*
    rm -rf ${PATH_DOMAIN}/keys/*
    rm -rf ${PATH_DOMAIN}/state/*
    rm -rf ${PATH_DOMAIN}/blockstore/*
  else
    sudo docker-compose -f ./diva.yml down
  fi
fi

if [[ ! -f genesis/block.v4.json ]]
then
  running "Creating Genesis Block using I2P"

  cp ${PROJECT_PATH}/build/genesis-i2p.yml ./genesis-i2p.yml
  sudo docker-compose --log-level ERROR -f ./genesis-i2p.yml pull
  sudo SIZE_NETWORK=${SIZE_NETWORK} docker-compose -f ./genesis-i2p.yml up -d
  # wait a bit to make sure all keys are created
  sleep 30

  # shut down the genesis container and clean up
  sudo docker-compose --log-level ERROR -f ./genesis-i2p.yml down --volumes
  rm ./genesis-i2p.yml

  # handle joining
  if [[ -n ${JOIN_NETWORK} ]]
  then
    rm -rf ./genesis/block.v4.json
    cp ${PROJECT_PATH}/build/dummy.block.v4.json ./genesis/block.v4.json
  fi

  if [[ -f genesis/local.config ]]
  then
    ok "Genesis Block successfully created"
  else
    error "Failed to create Genesis Block"
    exit 4
  fi
fi

running "Creating diva.yml file"

JOIN_NETWORK=${JOIN_NETWORK} \
  SIZE_NETWORK=${SIZE_NETWORK} \
  BASE_DOMAIN=${BASE_DOMAIN} \
  BASE_IP=${BASE_IP} \
  PORT=${PORT} \
  NODE_ENV=${NODE_ENV} \
  LOG_LEVEL=${LOG_LEVEL} \
  ${PROJECT_PATH}/node_modules/.bin/ts-node ${PROJECT_PATH}/build/build.ts

ok "Created diva.yml file"
