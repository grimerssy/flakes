FROM rust:slim-bookworm

ENV RUSTFLAGS "-C link-arg=-fuse-ld=lld"

RUN apt-get update
RUN apt-get -y install clang lld
RUN apt-get autoremove -y && apt-get clean -y
