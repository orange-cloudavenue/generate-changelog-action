FROM golang:alpine AS requirements

RUN go install github.com/hashicorp/go-changelog/cmd/changelog-build@latest

FROM alpine:3

COPY --from=requirements /go/bin/changelog-build /usr/local/bin/changelog-build

RUN apk add --no-cache git && \
    mkdir -p /changelog

WORKDIR /changelog

COPY changelog.tmpl .
COPY release-note.tmpl .
COPY generate-changelog.sh .

ENTRYPOINT ["/bin/sh","/changelog/generate-changelog.sh"]