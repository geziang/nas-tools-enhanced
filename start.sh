#!/bin/bash

export POETRY_VIRTUALENVS_CREATE=true
export POETRY_VIRTUALENVS_IN_PROJECT=false

poetry install
poetry run python run.py