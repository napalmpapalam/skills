# docker

Docker conventions. One auto-triggered skill carrying the Dockerfile authoring rules.

## Skills

- `dd:docker:dockerfile` — minimal pinned base images, build context and `.dockerignore`, layer cache order, chained `RUN`, `COPY` over `ADD`, multi-stage builds, BuildKit secrets, non-root users, PID 1 signal handling.

The skill is scoped to **authoring** a Dockerfile — what the model writes into the file. CI-side enforcement (hadolint and friends) is deliberately out of scope; it belongs to the pipeline, not to the file.
