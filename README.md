# Interactive Brokers Gateway in Docker ![Build Status](https://github.com/dvasdekis/ib-gateway-docker-gcp/workflows/Test%20and%20Publish/badge.svg "Build Status")

This repo takes mvberg's work and optimises it (targeting a e2-small instance on GCP):

* Replaces IB Controller with IBC
* Ubuntu 20.04 (Default of 16.04 isn't docker optimised)
* Removed installers after they are no longer used
* Works with Stackdriver logging
* Optimization of the Java runtime options
* VNC scripting (which didn't restart the container on error) fixed via Supervisor

Despite being optimised for GCP, this still works nicely in a local Docker instance, with [IBC, successor of IB Controller](https://github.com/IbcAlpha/IBC) 

### Latest Versions

* TWS Gateway: v981.3d (Current Stable): 
  * **Must download script [here](https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh) prior to building containers.
    It's too large for GitHub.**
* IBC (new IB Controller): v3.11.0
* ib_insync: v0.9.69

### Docker Hub image

* [dvasdekis/ib-gateway-docker](https://hub.docker.com/r/dvasdekis/ib-gateway-docker)

## Getting Started

Due to file size constraints, you **must** download the IB Gateway script from Interactive Brokers in order to build the containers. The most recent version is 981.3d. If that gets bumped beyond 981, this repo might require updates. Run the following:

```commandline
wget -O ibgateway-stable-standalone-linux-9813d-x64.sh https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
```

Start an instance locally using Docker-Compose.

To start an instance on Google Cloud:
`gcloud compute instances create-with-container my-ib-gateway --container-image="docker.io/dvasdekis/ib-gateway-docker:v981" --container-env-file="./ibgateway.env" --machine-type=e2-small --container-env TWSUSERID="$tws_user_id",TWSPASSWORD="$tws_password",TRADING_MODE=paper --zone="my-preferred-zone"`

#### Logging in with VNC:

1. Uncomment the lines marked 'ports' in docker-compose
2. SSH into server and run `mkdir ~/.vnc && echo "mylongpassword" > ~/.vnc/passwd && x11vnc -passwd mylongpassword -display ":99" -forever -rfbport 5900` as root
3. Log in with a remote VNC client using `mylongpassword` on port 5901

#### Expected output

You will now have the IB Gateway app running on port 4003 for Live trading and 4004 for Paper trading.

See [docker-compose.yml](docker-compose.yml) for configuring VNC password, accounts and trading mode.

All IPs on your network are able to connect to your box and place trades - so please do not open your box to the internet.

#### Running the container locally:

Use the command `docker run -e TWSUSERID=tws_user_id -e TWSPASSWORD=tws_password -e TRADING_MODE=paper -e XVFB_ARGS='"-ac -screen 0 1024x768x16 +extension RANDR"' -p 4002:4004 dvasdekis/ib-gateway-docker`
to run a container instance locally and connect to it on port 4002.

### Troubleshooting

##### Read-Only API warning:
IBC has decided not to support switching off the Read-Only checkbox (on by default) on the API Settings page.

To work around it for some operations, you'll need to write a file called ibg.xml as a new file to `/root/Jts/*encrypted user id*/ibg.xml`. The ibg.xml file can be found in this folder after a succesful run and close, and contains the application's settings from the previous run.


##### 
Sometimes, when running in non-daemon mode, you will see this:

```java
Exception in thread "main" java.awt.AWTError: Can't connect to X11 window server using ':0' as the value of the DISPLAY variable.
```

You will have to remove the container `docker rm container_id` and run `docker-compose up` again.
