#!/bin/bash

export POETRY_VIRTUALENVS_CREATE=true
export POETRY_VIRTUALENVS_IN_PROJECT=false

#python -m poetry install
python -m poetry run python run.py
