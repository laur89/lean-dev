# lean-dev
note [Dockerhub](https://cloud.docker.com/repository/docker/layr/lean-dev/builds)
settings _should_ trigger auto-build on baseimage bump; untested if that works.

Any commit on this repo also causes build to be triggered.

Use it from your `docker-compose` as follows:


    services:
      dev:
        build:
          context: ./lean-dev
          args:
            USERNAME: $USERNAME
            SRC_MOUNT: $SRC_MOUNT
        working_dir: $SRC_MOUNT
        container_name: lean-dev
        environment:
          - HOST_USER_ID=$UID
          - HOST_GROUP_ID=$GID
        ports:
          - "2223:22"
        volumes:
          - ./:${SRC_MOUNT}:cached
        tty: true

Note some of the env vars (like `USERNAME` & `SRC_MOUNT`) are to be provided either
by `.env` file, or directly passed to docker-compose.
