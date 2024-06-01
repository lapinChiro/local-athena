FROM rust:1.78.0
RUN apt-get update && apt-get -y install \
  libssl-dev \
  pkg-config \
  curl \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

RUN cargo install cargo-watch && \
  rustup component add rustfmt clippy

EXPOSE 3511
