# syntax=docker.io/docker/dockerfile:1.4
FROM --platform=linux/riscv64 cartesi/python:3.10-slim-jammy as build-stage

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential=12.9ubuntu3 \
    && rm -rf /var/lib/apt/lists/* \
    && find /var/log \( -name '*.log' -o -name '*.log.*' \) -exec truncate -s 0 {} \;

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .

RUN pip install -r requirements.txt --no-cache \
    && find /opt/venv -type d -name __pycache__ -exec rm -r {} +


# runtime stage: produces final image that will be executed
FROM --platform=linux/riscv64 cartesi/python:3.10-slim-jammy

LABEL io.sunodo.sdk_version=0.1.0
LABEL io.cartesi.rollups.ram_size=128Mi

COPY --from=build-stage /opt/venv /opt/venv

RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends busybox-static=1:1.30.1-7ubuntu3
rm -rf /var/lib/apt/lists/*
EOF

COPY --from=sunodo/machine-emulator-tools:0.11.0-ubuntu22.04 / /
ENV PATH="/opt/venv/bin:/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp

COPY echo-voucher.py .
COPY networks.json .
COPY entrypoint.sh .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ARG NETWORK=localhost
RUN echo ${NETWORK} > NETWORK

ENTRYPOINT ["NETWORK=$(cat /opt/cartesi/dapp/NETWORK)"]
CMD ["/opt/cartesi/dapp/entrypoint.sh"]
