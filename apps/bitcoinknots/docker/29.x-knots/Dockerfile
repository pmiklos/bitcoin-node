# This Dockerfile builds Bitcoin Knots and packages it into a minimal `final` image

# VERSION of Bitcoin Knots to be build
#   NOTE: Unlike our other images this one is NOT prefixed with `v`,
#           as many things (like download URLs) use this form instead.
ARG VERSION=29.3.knots20260210

# Define default versions so that they don't have to be repeated throughout the file
ARG VER_ALPINE=3.20

# $USER name, and data $DIR to be used in the `final` image
ARG USER=bitcoind
ARG DIR=/data

# Choose where to get bitcoind sources from, options: release, git
#   NOTE: Only `SOURCE=git` can be used for RC releases
ARG SOURCE=release

# Choose where to get BerkeleyDB from, options: prebuilt, compile
#   NOTE: When compiled here total execution time exceeds allowed CI limits, so pre-built one is used by default
ARG BDB_SOURCE=prebuilt



#
## `preparer-base` installs dependencies needed by both ways of fetching the source,
#       as well as imports GPG keys needed to verify authenticity of the source.
#
FROM alpine:${VER_ALPINE} AS preparer-base

RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache gnupg

# Guix Builder Keys: https://github.com/bitcoinknots/guix.sigs/tree/main/builder-keys
ENV KEYS="982A193E3CE0EED535E09023188CBB2648416AD5 \
    9EDAFF80E080659604F4A76B2EBB056FD847F8A7 \
    ED9BDF7AD6A55E232E84524257FF9BDBCC301009 \
    152812300785C96444D3334D17565732E08E5E41 \
    C1BCB7169AF1A07A0C5E471A047509FA0A6D7350 \
    2DEA254A2055EFD1DA82BB2315D2B66859703841 \
    95636F3538D9262765AB29BEE952E584CA8C0F45 \
    658E64021E5793C6C4E15E45C2E581F5B998F30E \
    F4FC70F07310028424EFC20A8E4256593F177720 \
    D1DBF2C4B96F2DEBF4C16654410108112E7EA81F \
    71A3B16735405025D447E8F274810B012346C9A6 \
    DAED928C727D3E613EC46635F5073C4F4882FFFC \
    93CB4961F69A65082D4410802CBA8253089655C3 \
    1A3E761F19D2CC7785C5502EA291A2C45D0C504A \
    1D5889CB9E0564C154E18BB512EC9519DB43CC27 \
    55058E8947E136A64F9E8AD5C4512A878E4AC2BF \
    32FE1E61B1C711186CA378DEFD8981F1BC41ABB9 \
    1D70CBE4B42239445617D33DD316C8140185B647"

RUN gpg --batch --recv-keys $KEYS && gpgconf --kill all

#
## Option #1: [default] Fetch bitcoind source from release tarballs
#
FROM preparer-base AS preparer-release

ARG VERSION

WORKDIR /bitcoin

ADD https://bitcoinknots.org/files/29.x/$VERSION/SHA256SUMS.asc ./
ADD https://bitcoinknots.org/files/29.x/$VERSION/SHA256SUMS ./
ADD https://bitcoinknots.org/files/29.x/$VERSION/bitcoin-$VERSION.tar.gz ./

RUN gpg --batch --no-tty --verify SHA256SUMS.asc SHA256SUMS 2>&1 | grep "Good signature"

RUN grep "bitcoin-$VERSION.tar.gz" SHA256SUMS | sha256sum -c

# Extract directly into /bitcoin
RUN tar -xzf bitcoin-$VERSION.tar.gz --strip-components=1 && \
    rm -f bitcoin-$VERSION.tar.gz

#
## Option #2: Fetch bitcoind source from GitHub
#
FROM preparer-base AS preparer-git

ARG VERSION

WORKDIR /bitcoin

RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache git

# Fetch the source code at a specific TAG
RUN git clone -b "v$VERSION" --depth=1 https://github.com/bitcoinknots/bitcoin.git .

# Verify tag
RUN git verify-tag "v$VERSION"



#
## Alias to go around `COPY` not accepting ARGs in value passed to `--from=`
#
FROM preparer-${SOURCE} AS preparer



#
## `berkeleydb-prebuilt` downloads a pre-built BerkeleyDB
#
ARG TARGETARCH
FROM lncm/berkeleydb:v4.8.30.NC${TARGETARCH:+-${TARGETARCH}} AS berkeleydb-prebuilt

#
## `berkeleydb-compile` placeholder
#
FROM alpine:${VER_ALPINE} AS berkeleydb-compile
RUN echo "BerkeleyDB compilation not implemented yet."


FROM berkeleydb-${BDB_SOURCE} AS berkeleydb



#
## `builder` builds Bitcoin Knots using CMake
#
FROM alpine:${VER_ALPINE} AS builder

ARG VERSION
ARG SOURCE

RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache \
    cmake \
    pkgconf \
    boost-dev \
    sqlite-dev \
    build-base \
    chrpath \
    file \
    libevent-dev \
    libressl \
    linux-headers \
    zeromq-dev

# Fetch pre-built berkeleydb
COPY  --from=berkeleydb /opt/  /opt/

WORKDIR /bitcoin/

# Copy bitcoin source
COPY  --from=preparer /bitcoin/  ./

ENV BITCOIN_PREFIX=/opt/bitcoin-$VERSION

# Build using CMake
RUN cmake -B build \
    -DCMAKE_INSTALL_PREFIX="$BITCOIN_PREFIX" \
    -DBUILD_GUI=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_BENCH=OFF \
    -DBUILD_CLI=ON \
    -DBUILD_TX=ON \
    -DBUILD_UTIL=ON \
    -DBUILD_DAEMON=ON \
    -DENABLE_WALLET=ON \
    -DWITH_SQLITE=ON \
    -DWITH_BDB=ON \
    -DBerkeleyDB_INCLUDE_DIR=/opt/db4/include \
    -DBerkeleyDB_LIBRARY=/opt/db4/lib/libdb_cxx.a \
    -DBerkeleyDB_LIBRARY_RELEASE=/opt/db4/lib/libdb_cxx.a \
    -DREDUCE_EXPORTS=ON \
    -DINSTALL_MAN=OFF \
    -DWITH_ZMQ=ON \
    -DWITH_CCACHE=OFF

RUN cmake --build build -j$(( $(nproc) + 1 ))
RUN cmake --install build

# List installed binaries pre-strip & strip them
RUN ls -lh "$BITCOIN_PREFIX/bin/"
RUN strip -v "$BITCOIN_PREFIX/bin/bitcoin"*

# List installed binaries post-strip & print their checksums
RUN ls -lh "$BITCOIN_PREFIX/bin/"
RUN sha256sum "$BITCOIN_PREFIX/bin/bitcoin"*



#
## `final` aggregates build results into a minimal image
#
FROM alpine:${VER_ALPINE} AS final

ARG VERSION
ARG USER
ARG DIR

RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache \
    libevent \
    libsodium \
    libstdc++ \
    libzmq \
    sqlite-libs

COPY  --from=builder /opt/bitcoin-$VERSION/bin/bitcoin*  /usr/local/bin/

# NOTE: Default GID == UID == 1000
RUN adduser --disabled-password \
    --home "$DIR/" \
    --gecos "" \
    "$USER"

USER $USER

# Prevents `VOLUME $DIR/.bitcoind/` being created as owned by `root`
RUN mkdir -p "$DIR/.bitcoin/"

# Expose volume containing all `bitcoind` data
VOLUME $DIR/.bitcoin/

# REST interface
EXPOSE 8080

# P2P network (mainnet, testnet & regnet respectively)
EXPOSE 8333 18333 18444

# RPC interface (mainnet, testnet & regnet respectively)
EXPOSE 8332 18332 18443

# ZMQ ports (for transactions & blocks respectively)
EXPOSE 28332 28333

ENTRYPOINT ["bitcoind"]

CMD ["-zmqpubrawblock=tcp://0.0.0.0:28332", "-zmqpubrawtx=tcp://0.0.0.0:28333"]
