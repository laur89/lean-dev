# lean-dev
Any commit on this repo causes build to be triggered in my private infra.

TODO: start using dependabot to bump CI build/update our baseimage ver whenever
the LEAN foundation image is updated.

## Usage

### use-prebuilt image (recommended)

~dockerhub builds an image in its pipeline: [layr/lean-dev](https://hub.docker.com/r/layr/lean-dev/builds);
You may use this image instead of building yourself; note in this case the non-root
user is `me`.~ As Docker stopped offering free build time, I've migrated image
creation to private stack. Sorry.

Example  `docker-compose` usage:


    services:
      dev:
        image: layr/lean-dev:latest
        working_dir: $SRC_MOUNT
        container_name: lean-dev
        environment:
          - HOST_USER_ID=$UID
          - HOST_GROUP_ID=$GID
          - SRC_MOUNT=$SRC_MOUNT
        ports:
          - "2223:22"
        volumes:
          - ./:${SRC_MOUNT}:cached
        tty: true

Note env var `SRC_MOUNT` needs to be provided by `.env` file, or manually defined 
in docker-compose.


### build yourself

Use it from your `docker-compose` as follows in order to build the image yourself:


    services:
      dev:
        build:
          context: ./lean-dev
          args:
            USERNAME: $USERNAME
        working_dir: $SRC_MOUNT
        container_name: lean-dev
        environment:
          - HOST_USER_ID=$UID
          - HOST_GROUP_ID=$GID
          - SRC_MOUNT=$SRC_MOUNT
        ports:
          - "2223:22"
        volumes:
          - ./:${SRC_MOUNT}:cached
        tty: true

Note the env vars `USERNAME` & `SRC_MOUNT` are to be provided either
by `.env` file, or manually define 'em in docker-compose.


