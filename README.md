# Interactive Brokers Gateway in Docker ![Build Status](https://github.com/dvasdekis/ib-gateway-docker-gcp/workflows/Test%20and%20Publish/badge.svg "Build Status")

This repo takes mvberg's work and optimises it (targeting a e2-small instance on GCP):

* Replaces IB Controller with IBC
* Ubuntu 20.04 (Default of 16.04 isn't docker optimised)
* Removed installers after they are no longer used
* Works with Stackdriver logging
* Optimisation of the Java runtime options
* VNC scripting (which didn't restart the container on error) fixed via Supervisor

Despite being optimised for GCP, this still works nicely in a local Docker instance, with [IBC, successor of IB Controller](https://github.com/IbcAlpha/IBC) 

* TWS Gateway: v978.2c (Current Stable)
* IBC (new IB Controller): v3.8.2

### Docker Hub image

* [dvasdekis/ib-gateway-docker](https://hub.docker.com/r/dvasdekis/ib-gateway-docker)

### Getting Started

Start an instance locally using Docker-Compose.

To start an instance on Google Cloud:
`gcloud compute instances create-with-container my-ib-gateway --container-image="docker.io/dvasdekis/ib-gateway-docker:v978" --container-env-file="./ibgateway.env" --machine-type=e2-small --container-env TWSUSERID="$tws_user_id",TWSPASSWORD="$tws_password",TRADING_MODE=paper --zone="my-preferred-zone"`

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

You may also add `-e READ_ONLY_API=no` to override the default TWS "read-only API" setting.

### Troubleshooting

##### 
Sometimes, when running in non-daemon mode, you will see this:

```java
Exception in thread "main" java.awt.AWTError: Can't connect to X11 window server using ':0' as the value of the DISPLAY variable.
```

You will have to remove the container `docker rm container_id` and run `docker-compose up` again.
