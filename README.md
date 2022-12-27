# DIVA "Dockerized"
This project has the following purpose: even if DIVA consists of several independent modules, it still should be easy to have the complete environment available.

Online Demo and Test sites:
* https://testnet.diva.exchange - The public DIVA testnet. Everybody can join.

## Get Started
Basically there are two options: either join an existing network or create your own.

To start with, it is recommended to join the existing DIVA test network. The test network can be explored on https://testnet.diva.exchange.

### Windows Subsystem for Linux (WSL)
**IMPORTANT**: Make sure you have WSL and sudo ready on your windows machine. Therefore you can follow https://linuxhint.com/run-sudo-command-windows/.

### Docker Compose
**IMPORTANT**: Make sure you have [Docker Compose](https://docs.docker.com/compose/install/) installed. Check your Docker Compose installation by executing `docker compose version` in a terminal.

### Cloning the Code
If you don't have a github account, create one on github.com. Fork the project to your own github repository.

Then clone the code repository:
```
git clone https://github.com/YOUR-GITHUB-USERNAME/diva-dockerized.git
cd diva-dockerized
npm i
```
**IMPORTANT**: Make sure all shell files have line endings LF.

Now, ~~either build your own local testnet or~~ join the existing [DIVA testnet](https://testnet.diva.exchange). 

### Join the public DIVA Test Network
To join the DIVA test network, build a local docker compose file first. This is an automated process. Here is an example on how to join the DIVA test network via I2P (it will ask to allow changes on the machine, since it has to access the docker daemon and this access needs elevated privileges):
```
bash bin/build.sh
```

To create the docker compose file run:
```
.\node_modules\.bin\ts-node build\build.ts
```

After building the docker compose file, the containers can be **started**:
```
bash bin/start.sh
```  

#### Check I2P
The webconsoles of I2P are running within your local docker containers. Check them using http://127.19.72.11:7070/ and http://127.19.72.12:7070/. These two URL's are assuming that the default configuration is used. If you changed the IP config (see below, environment variable HOST_BASE_IP), you have to adapt the URL's because the docker container will run on different IP's.

#### Check the Synchronization
Now please visit http://127.19.72.200:3920 (the explorer). Refresh it from time to time to see whether your local chain syncronizes with the diva testnet. Sooner or later (like 10 minutes) it should be the same as here https://testnet.diva.exchange.

#### Check API
Go to http://127.19.72.21:17468/about to check if the api is running. See https://github.com/diva-exchange/divachain#api-endpoints for more information about available api endpoints.

#### Warning: Joining the Very First Time
If you are joining the network for the _very first time_, it will take a longer while (maybe even up to 20 minutes) until you have a stable I2P network available. Please be patient. Check the logs of divachain, `docker logs n1.chain.join.testnet.diva.i2p`, to see whether it synchronizes. If it does not synchronize properly restart it (see Troubleshooting below).

#### Troubleshooting 
1. Explore the local docker environment, using `docker ps -a`.
2. Check the logs, using `docker logs n1.chain.join.testnet.diva.i2p`
3. If synchronization is not working properly (like the very first time), try to restart the chain after a few minutes: `docker restart n1.chain.join.testnet.diva.i2p`
4. Access local explorer, http://127.19.72.200:3920 (URL as set in default config, see HOST_BASE_IP)
5. Access local I2P webconsole, http://127.19.72.11:7070/ and http://127.19.72.12:7070/ (URL as set in default config)

#### Stopping
To **stop** locally running DIVA Test Network containers, execute:
```
bash bin/halt.sh
```

#### Restarting
To **restart** the locally running DIVA Test Network containers, execute:
```
bash bin/restart.sh
```
This restarts the complete stack (I2P, divachain, protocol).

### Purge DIVA Test Network data
**Warning** This deletes all your local diva data within the folder `build/domains/join.testnet.diva.i2p` (keys, blockchain data).

To purge local testnet data, execute:
```
bash bin/purge.sh
```

### Leave the DIVA Network
tbd.

### Local, I2P based DIVA Test Network
**IMPORTANT**: Currently not supported
To create an I2P-based DIVA test network, build a local docker compose file first. This is an automated process. Here is an example:
```
BASE_IP=172.19.73. HOST_BASE_IP=127.19.73. BASE_DOMAIN=testnet.local bin/build.sh
```

After building the docker compose file, the containers can be **started**:
```
BASE_DOMAIN=testnet.local bin/start.sh
```  

It is now possible to explore the local docker environment using docker commands, like `docker ps -a`.

To **stop** locally running DIVA Test Network containers, execute:
```
BASE_DOMAIN=testnet.local bin/halt.sh
```

### Purge local DIVA data
**IMPORTANT**: Currently not supported
**Warning** This deletes all your local DIVA data within the folder `build/domains/testnet.local` (keys, blockchain data).

To purge all local data, execute:
```
BASE_DOMAIN=testnet.local bin/purge.sh
```

### Development: Use of Specific Docker Images
**IMPORTANT**: Currently not supported
It is possible to specify docker images to build the .yml file used by docker compose.
Use the environment variables IMAGE_I2P, IMAGE_CHAIN, IMAGE_PROTOCOL and IMAGE_EXPLORER to pass specific image names to the build process. Here is an example:

```
DIVA_TESTNET=1 LOG_LEVEL=trace IMAGE_CHAIN=divax/divachain:develop bin/build.sh
```

This will build a .yml file using a specific docker image as divachain.

## Environment Variables

### DIVA_TESTNET
Boolean: 1 (true) or 0

Default: `1`

### JOIN_NETWORK
String: network entrypoint (bootstrap)

Default: `(empty)` 

### SIZE_NETWORK
Integer, >=7, <=15

Default: `1`

### BASE_DOMAIN
String: valid domain name

Default: `join.testnet.diva.i2p` 

### HOST_BASE_IP
String: valid local base IP, like 127.19.72. Used to map the docker containers to the host. 

Default: `127.19.72.`

### BASE_IP
String: valid local base IP, like 172.19.72. Used as IP's for docker containers.

Default: `172.19.72.`

### PORT
Integer: >1024, <48000

Default: `17468`

### HAS_EXPLORER
Boolean: 1 (true) or 0

Default: `1`

### HAS_PROTOCOL
Boolean: 1 (true) or 0

Default: `1`

### NODE_ENV
String: production, development

Default: `production`

### LOG_LEVEL
Logging level of NodeJS applications, like divachain

String: trace, info, warn, error, critical

Default: `info`

### PURGE
Boolean: 1 (true) or 0

Default: `0`

### I2P_LOGLEVEL
Logging level of I2P

String: debug, info, warn, error, none

Default: `none`

## Contributions
Contributions are very welcome. This is the general workflow:

1. Fork from https://github.com/diva-exchange/diva-dockerized/
2. Pull the forked project to your local developer environment
3. Make your changes, test, commit and push them
4. Create a new pull request on github.com

It is strongly recommended to sign your commits: https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key

If you have questions, please just contact us (see below).

## Donations

Your donation goes entirely to the project. Your donation makes the development of DIVA.EXCHANGE faster. Thanks a lot.

### XMR

42QLvHvkc9bahHadQfEzuJJx4ZHnGhQzBXa8C9H3c472diEvVRzevwpN7VAUpCPePCiDhehH4BAWh8kYicoSxpusMmhfwgx

![XMR](https://www.diva.exchange/wp-content/uploads/2020/06/diva-exchange-monero-qr-code-1.jpg)

or via https://www.diva.exchange/en/join-in/

### BTC

3Ebuzhsbs6DrUQuwvMu722LhD8cNfhG1gs

![BTC](https://www.diva.exchange/wp-content/uploads/2020/06/diva-exchange-bitcoin-qr-code-1.jpg)

## Contact the Developers

On [DIVA.EXCHANGE](https://www.diva.exchange) you'll find various options to get in touch with the team.

Talk to us via [Telegram](https://t.me/diva_exchange_chat_de) (English or German).

## License

[AGPLv3](https://github.com/diva-exchange/diva-dockerized/blob/main/LICENSE)
