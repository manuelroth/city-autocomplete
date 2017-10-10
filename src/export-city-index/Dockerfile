FROM postgres:10

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app/
RUN chmod +x ./export_city_index.sh

CMD ["./export_city_index.sh"]
