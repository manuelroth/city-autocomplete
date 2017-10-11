FROM alpine:latest

RUN apk add --update bash zip wget sed
RUN mkdir -p /usr/src/app
COPY . /usr/src/app/
WORKDIR /usr/src/app/
RUN chmod +x ./download_geonames.sh

CMD ["./download_geonames.sh"]
