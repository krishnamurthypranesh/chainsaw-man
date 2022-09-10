#!/bin/bash

pip install --no-cache-dir --upgrade -r /code/requirements.txt

uvicorn main:app --host 0.0.0.0 --port 80 --reload