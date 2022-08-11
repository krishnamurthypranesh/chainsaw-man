FROM python:3.9

WORKDIR /code

RUN mkdir docker

ENTRYPOINT [ "docker/start_backend.sh" ]