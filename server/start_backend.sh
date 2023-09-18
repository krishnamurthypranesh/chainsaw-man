#!/bin/bash

pipenv install

export PYTHONPATH=$PYTHONPATH:$(pwd)

pipenv run seed_db

pipenv run uvicorn app.main:app --host 0.0.0.0 --port 80 --reload
