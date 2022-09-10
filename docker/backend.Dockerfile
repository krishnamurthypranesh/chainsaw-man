FROM python:3.9

WORKDIR /code

RUN mkdir docker

ENTRYPOINT [ "./start_backend.sh" ]