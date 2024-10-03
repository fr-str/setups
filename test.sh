#!/run/current-system/sw/bin/bash

docker build -t archtest . 
docker run --rm -it -v ./:/home/dupka/setups archtest:latest bash

