# This Dockerfile builds Bitcoin Core 32.x from source and packages it into a minimal Alpine image

ARG VERSION=32.1
ARG VER_ALPINE=3.20

FROM alpine:${VER_ALPINE} AS builder

ARG VERSION

RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache \
    build-base \
    cmake \
    linux-headers \
    pkgconf \
    python3 \
    boost-dev \
    sqlite-dev \
    zeromq-dev

WORKDIR /bitcoin

COPY . .

RUN rm -rf .git build

ENV BITCOIN_PREFIX=/opt/bitcoin-${VERSION}

RUN cmake -B build \
    -DCMAKE_INSTALL_PREFIX="${BITCOIN_PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_DAEMON=ON \
    -DBUILD_CLI=ON \
    -DBUILD_TX=ON \
    -DBUILD_UTIL=ON \
    -DENABLE_WALLET=ON \
    -DBUILD_WALLET_TOOL=ON \
    -DWITH_ZMQ=ON \
    -DBUILD_GUI=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_BENCH=OFF \
    -DENABLE_IPC=OFF \
    -DREDUCE_EXPORTS=ON \
    -DINSTALL_MAN=OFF \
    -DWITH_CCACHE=OFF

RUN cmake --build build -j$(( $(nproc) + 1 ))
RUN cmake --install build

RUN strip -v "${BITCOIN_PREFIX}/bin/bitcoin"*

FROM alpine:${VER_ALPINE} AS final

ARG VERSION
ARG USER=bitcoind
ARG DIR=/data

RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache \
    libstdc++ \
    libzmq \
    sqlite-libs

COPY --from=builder /opt/bitcoin-${VERSION}/bin/bitcoin* /usr/local/bin/

RUN adduser --disabled-password \
    --home "$DIR/" \
    --gecos "" \
    "$USER"

USER $USER

RUN mkdir -p "$DIR/.bitcoin/"

VOLUME $DIR/.bitcoin/

# REST interface
EXPOSE 8080

# P2P network (mainnet, testnet & regtest respectively)
EXPOSE 8333 18333 18444

# RPC interface (mainnet, testnet & regtest respectively)
EXPOSE 8332 18332 18443

# ZMQ ports (for transactions & blocks respectively)
EXPOSE 28332 28333

ENTRYPOINT ["bitcoind"]

CMD ["-zmqpubrawblock=tcp://0.0.0.0:28332", "-zmqpubrawtx=tcp://0.0.0.0:28333"]
