FROM golang:1.27-alpine AS build
WORKDIR /src
ENV CGO_ENABLED=0
COPY go.mod go.sum ./
RUN go mod download
COPY main.go ./
COPY templates ./templates
RUN go build -trimpath -ldflags="-s -w" -o /out/caffe-board .

FROM alpine:3.24
RUN apk --no-cache upgrade && apk add --no-cache tini \
    && addgroup -S app && adduser -S -G app -h /app app
WORKDIR /app
COPY --from=build /out/caffe-board /app/caffe-board
COPY --from=build /src/templates /app/templates
ENV PORT=8080
EXPOSE 8080
USER app
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/app/caffe-board"]
