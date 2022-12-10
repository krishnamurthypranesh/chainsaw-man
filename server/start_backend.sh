#!/bin/bash

pipenv install

pipenv shell

pipenv run uvicorn main:app --host 0.0.0.0 --port 80 --reload