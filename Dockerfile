FROM alpine:3.4
RUN apk add --update ca-certificates
ARG GIT_COMMIT=unkown
ARG GIT_BRANCH=unkown
LABEL git-commit=$GIT_COMMIT
LABEL git-branch=$GIT_BRANCH
ADD /build/travis-test/test .

ENTRYPOINT ["/test"]

