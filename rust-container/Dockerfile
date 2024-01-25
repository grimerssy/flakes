FROM lukemathwalker/cargo-chef:0.1.62-rust-1.75-slim-buster as cargo-chef
WORKDIR /app

FROM gcr.io/distroless/cc-debian10:nonroot as distroless

FROM scratch as files
COPY Cargo.toml Cargo.lock .
COPY src src

FROM cargo-chef AS planner
COPY --from=files . .
RUN cargo chef prepare

FROM cargo-chef as prepared
COPY --from=planner /app/recipe.json .

FROM prepared AS builder
RUN cargo chef cook --release
COPY --from=files . .
RUN cargo build --release

FROM distroless AS release
COPY --from=builder /app/target/release/rust app
ENTRYPOINT ["./app"]

FROM prepared as debug 
RUN cargo chef cook
COPY --from=files . .
RUN cargo build
ENTRYPOINT ["cargo", "run"]

FROM prepared as test
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin
RUN cargo chef cook --tests
COPY --from=files . .
RUN cargo build --tests
ENTRYPOINT ["cargo", "test"]

FROM release
