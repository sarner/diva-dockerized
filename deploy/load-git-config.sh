#!/usr/bin/env bash
#
# Copyright (C) 2022 diva.exchange
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
# Author/Maintainer: DIVA.EXCHANGE Association, https://diva.exchange
#

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/../
cd ${PROJECT_PATH}
PROJECT_PATH=`pwd`

NAME_PROFILE=${1:-}

if [[ ! -f "${PROJECT_PATH}/deploy/profile/${NAME_PROFILE}" ]]; then
    echo "${PROJECT_PATH}/deploy/profile/${NAME_PROFILE} not found"
    exit 1
fi

source "${PROJECT_PATH}/deploy/profile/${NAME_PROFILE}"

git checkout develop
git fetch --all
git merge main

USER_NAME=${USER_NAME:-}
USER_EMAIL=${USER_EMAIL:-}
echo "Loaded: \"${USER_NAME} <${USER_EMAIL}>\""

echo ${NAME_PROFILE} >${PROJECT_PATH}/deploy/profile/.loaded
