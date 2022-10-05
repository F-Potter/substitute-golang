FROM golang:1.18-bullseye

RUN go install github.com/beego/bee/v2@latest

ENV GO111MODULE=on
ENV GOFLAGS=-mod=vendor

ENV APP_HOME /go/src/substitute
RUN mkdir -p "$APP_HOME"

WORKDIR "$APP_HOME"
COPY /go.mod ./
COPY /src/ ./
EXPOSE 8080
CMD ["bee", "run"]
