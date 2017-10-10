FROM node:8.6

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app/

RUN npm install -g algolia-csv

CMD algolia-upload $APP_ID $API_KEY $INDEX_NAME /usr/src/app/export/city_index.csv --geo-colums=lat,lng
