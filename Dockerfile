# https://hub.docker.com/_/node
ARG node_ver=15
FROM node:${node_ver}-alpine

ARG haraka_ver=2.8.25
ARG build_rev=0
