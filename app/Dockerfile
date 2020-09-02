FROM python:3.8
RUN mkdir /app
WORKDIR /app
ENV PYTHONPATH=${PYTHONPATH}:${PWD}
RUN pip3 install poetry
RUN poetry config virtualenvs.create false
COPY pyproject.toml poetry.lock /app/
RUN poetry install --no-dev
COPY app.py /app/

EXPOSE 5000
CMD FLASK_RUN_HOST=0.0.0.0 flask run 