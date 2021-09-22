# docker-nginx-ssl-proxy

A simple to configure nginx SSL proxy useful for local development. This utility supports multiple SSL domains on one
port, allowing for quick proxying to multiple destinations using only one service.

## Configuration

For docker-compose, see [docker-compose.yml](./docker-compose.yml) for an example.

`HOSTNAMES` - Configure one or more hostnames, comma separated. Each hostname should have a matching entry in TARGETS.

`TARGETS` - Configure one or more hostnames, comma separated. Each hostname should have a matching entry in TARGETS.
