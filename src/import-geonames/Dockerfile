FROM postgres:10

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app/
RUN chmod +x ./import_geonames.sh

CMD ["./import_geonames.sh"]
