FROM golang:alpine AS requirements

RUN go install github.com/hashicorp/go-changelog/cmd/changelog-build@latest

FROM alpine:3

COPY --from=requirements /go/bin/changelog-build /usr/local/bin/changelog-build

RUN apk add --no-cache git bash && \
    mkdir -p /changelog

WORKDIR /github/workspace

COPY changelog.tmpl /changelog
COPY release-note.tmpl /changelog
COPY generate-changelog.sh changelog

ENTRYPOINT ["/bin/bash","/changelog/generate-changelog.sh"]