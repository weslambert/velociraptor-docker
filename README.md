# velociraptor-docker
Run [Velocidex Velociraptor](https://github.com/Velocidex/velociraptor) server with Docker

#### Install

1. Ensure [docker-compose](https://docs.docker.com/compose/install/) is installed on the host
2. `git clone https://github.com/weslambert/velociraptor-docker`
3. `cd velociraptor-docker`
4. Change credential values in `.env` as desired
5. Run `sudo bash build.sh` to build the latest velociraptor version locally
6. `docker-compose up` (or `docker-compose up -d` for detached)
7. Access the Velociraptor GUI via https://\<hostip\>:8889 
  1. Default u/p is `admin/admin`
  2. This can be changed by running: 
  
  `docker exec -it velocraptor ./velociraptor --config server.config.yaml user add user1 user1 --role administrator`

#### Additional Features

Description|Change|Command
--|--|--
build latest release candidate|Install.5|`sudo bash build.sh latest-pre`
build specific release|Install.5|`sudo bash build.sh v6.5.0`
build latest release and push it to remote container registry|Install.5|`sudo bash build.sh --push-user <username> --push-token <token> --push-image test.local:1234/repo/image`
start a minion along the velociraptor master|Install.6|`docker-compose --profile minion up`

#### Notes

Linux, Mac, and Windows binaries are located in `/velociraptor/clients`, which should be mapped to the host in the `./velociraptor` directory if using `docker-compose`.  There should also be versions of each automatically repacked based on the server configuration.

Once started, edit `server.config.yaml` in `/velociraptor`, then run `docker-compose down/up` for the server to reflect the changes

#### Docker image
To pull only the Docker image:

`docker pull wlambert/velociraptor`
