#!/bin/sh
docker run --env-file .env.docker -p 8888:80 bp-rails:latest
