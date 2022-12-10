FROM python:3.10

WORKDIR /code

RUN python3 -m pip install pipenv

RUN mkdir docker

ENTRYPOINT [ "./start_backend.sh" ]