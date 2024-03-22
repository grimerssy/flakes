ARG RUST_VERSION=1.75

FROM lukemathwalker/cargo-chef:latest-rust-${RUST_VERSION}-slim-buster as cargo-chef
WORKDIR /app

FROM gcr.io/distroless/cc-debian10:nonroot as distroless

FROM cargo-chef as dev
RUN rustup component add clippy
RUN rustup component add rustfmt
RUN rustup component add rust-analyzer

FROM cargo-chef AS planner
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && touch src/lib.rs
RUN cargo chef prepare

FROM cargo-chef AS builder
ARG DATABASE_URL
COPY --from=planner /app/recipe.json .
RUN cargo chef cook --release
COPY Cargo.toml Cargo.lock ./
COPY src src
RUN cargo build --release

FROM distroless
COPY --from=builder /app/target/release/rust app
ENTRYPOINT ["./app"]
