#!/bin/bash

pipenv install

pipenv shell

export PYTHONPATH=$PYTHONPATH:$(pwd)

pipenv run seed_db

pipenv run uvicorn main:app --host 0.0.0.0 --port 80 --reload
