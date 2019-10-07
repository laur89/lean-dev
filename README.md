# lean-dev
note [Dockerhub](https://cloud.docker.com/repository/docker/layr/lean-dev/builds)
settings _should_ trigger auto-build on baseimage bump; untested if that works.

Any commit on this repo also causes build to be triggered.

Use it from your `docker-compose` like this:

    services:
      lean:
        build:
          context: ./lean-dev
          args:
            USERNAME: nonRootUserToCreate
        container_name: lean-dev
        environment:
          - HOST_USER_ID=$UID
          - HOST_GROUP_ID=$GID
        ports:
          - "2223:22"
        volumes:
          - ./:/home/nonRootUserToCreate/Lean:cached
        tty: true

