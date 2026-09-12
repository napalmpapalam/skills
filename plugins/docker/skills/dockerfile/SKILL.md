---
name: dockerfile
description: Dockerfile authoring rules — minimal pinned base images, build context and .dockerignore, layer cache order, chained RUN, COPY over ADD, multi-stage builds, BuildKit secrets, non-root users, PID 1 signal handling. Use whenever writing, editing, or reviewing a Dockerfile, .dockerignore, or a container image build; choosing a base image; cutting image size; fixing a slow or cache-busting build; passing build secrets; or when the user asks how to containerize a service.
---

# Dockerfile Rules

Four goals, in this order: **correct runtime**, **small image**, **fast cache**, **no secrets in layers**.
A layer is immutable — anything a layer writes ships in the image, even if a later layer deletes it.

## Base image

- Pick the smallest base that runs the artifact:
  - **Distroless** — compiled binaries with no shell needed. Smallest attack surface.
  - **Alpine** — static binaries, Go, Rust. musl, so check C dependencies first.
  - **Slim** — Python, Node.js. Debian userland without the build toolchain.
- **Pin an exact tag.** Never `latest` — the build stops being reproducible the moment upstream moves.
- Pin the digest when the build must be byte-identical: `node:22.11.0-alpine@sha256:…`.

```dockerfile
FROM node:22.11.0-alpine      # good — deterministic
FROM node:latest              # bad — a different image every rebuild
```

## Build context

The daemon receives the whole context directory before the build starts. A large context slows every build, even a fully cached one.

- Keep the context to the directory the build actually reads.
- **Always write a `.dockerignore`.** It cuts upload time and keeps secrets out of the image.

```
.git
node_modules
target
dist
*.log
.env
.env.*
**/*.pem
```

## Layer cache

Docker invalidates a layer and every layer after it when its inputs change. So order the file by change frequency: rarely-changed inputs first, source code last.

- **Copy the manifests, install dependencies, then copy the source.** Source edits then reuse the dependency layer.

```dockerfile
COPY package.json package-lock.json ./
RUN npm ci                    # cached until the manifests change
COPY . .                      # invalidated by every source edit
```

- **Chain one `RUN` per logical step** with `&&` and `\`. Clean the package cache inside the same `RUN` — a separate `RUN rm` leaves the files in the earlier layer.

```dockerfile
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*
```

- **Prefer `COPY` over `ADD`.** `ADD` also fetches URLs and auto-extracts archives, which makes cache behaviour hard to predict. Use `ADD` only to extract a local archive.

## Multi-stage builds

Compile in a stage that holds the SDK, source, and dev dependencies. Copy only the artifact into the runtime stage.

```dockerfile
FROM golang:1.23-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /out/app ./cmd/app

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/app /app
USER nonroot
ENTRYPOINT ["/app"]
```

- Name every stage (`AS build`) and copy by name, not by index.
- The compiler, the source, and the build cache never reach the final image.

## BuildKit

BuildKit runs independent stages in parallel, caches better, and is the only builder that mounts caches and secrets.

- **Docker Engine 23.0 and later: BuildKit is the default.** Plain `docker build` already uses it. Do not set `DOCKER_BUILDKIT=1` — it changes nothing.
- **Engine 18.09 to 22.x:** BuildKit exists but the classic builder is the default. Opt in per build with `DOCKER_BUILDKIT=1 docker build …`, or set `{"features":{"buildkit":true}}` in `/etc/docker/daemon.json`.
- **Engine below 18.09, or a CI runner you do not control:** treat mounts as unavailable. A `--mount` flag on the classic builder fails the build with a parse error.
- `docker buildx build` uses BuildKit on every version that ships buildx, so prefer it when the engine version is unknown.

- Declare the syntax directive on the first line when you use mounts:

```dockerfile
# syntax=docker/dockerfile:1
```

- Cache package downloads across builds with a cache mount:

```dockerfile
RUN --mount=type=cache,target=/root/.cache/go-build go build ./...
```

## Secrets

**Never put a credential in `ARG` or `ENV`.** Both persist in the image history, and `docker history` prints them. Deleting the file in a later layer does not remove it.

Mount the secret instead — it exists only for that `RUN`:

```dockerfile
RUN --mount=type=secret,id=npm_token \
    NPM_TOKEN="$(cat /run/secrets/npm_token)" npm ci
```

```bash
docker build --secret id=npm_token,src=./npm_token .
```

## Runtime user

Containers run as root by default. A container escape then starts from root on the host.

```dockerfile
RUN addgroup -S app && adduser -S -G app app
USER app
```

- Create the user in the runtime stage and switch before `ENTRYPOINT`.
- Give the user only the paths it must write. Keep the application files owned by root and read-only.
- Distroless images ship a `nonroot` user already — use the `:nonroot` tag and `USER nonroot`.

## PID 1 and signals

PID 1 does not get the default signal handlers. If the process ignores `SIGTERM`, `docker stop` waits the full timeout and then kills it, so shutdown is never graceful.

- **Use exec form**, so the process becomes PID 1 and receives the signal directly:

```dockerfile
ENTRYPOINT ["node", "server.js"]     # exec form — node is PID 1
ENTRYPOINT node server.js            # shell form — sh is PID 1, node gets nothing
```

- In an entrypoint script, hand over the process with `exec`:

```sh
#!/bin/sh
set -e
run-migrations
exec "$@"
```

- Add an init (`tini`, or `docker run --init`) only when the process spawns children and does not reap them.

## Review checklist

- [ ] Base image is minimal and pinned to an exact tag
- [ ] `.dockerignore` excludes `.git`, dependency dirs, build output, `.env`, keys
- [ ] Dependency install sits above the source `COPY`
- [ ] Each `RUN` cleans its own caches in the same instruction
- [ ] `ADD` appears only to extract a local archive
- [ ] Build tooling stays in a build stage
- [ ] No credential in `ARG` or `ENV`
- [ ] `USER` is non-root before `ENTRYPOINT`
- [ ] `ENTRYPOINT` / `CMD` use exec form
