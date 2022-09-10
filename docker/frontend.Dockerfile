FROM alpine:3.14

RUN apk add curl

WORKDIR /tmp

RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
RUN gunzip elm.gz
RUN mv elm ../bin
RUN chmod +x /bin/elm

RUN mkdir /code

RUN apk add --update nodejs npm

RUN npm install -g elm-live

WORKDIR /code

ENTRYPOINT [ "./start_frontend.sh" ]
