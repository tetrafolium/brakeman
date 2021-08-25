FROM python:alpine AS linter-stage

### Install yamllint tool ...
RUN pip3 install 'yamllint>=1.24.0,<1.25.0' && \
    echo "+++ $(yamllint --version)"

ENV REPOPATH="github.com/tetrafolium/brakeman"
ENV REPODIR="${GOPATH}/src/${REPOPATH}"

ARG OUTDIR
ENV OUTDIR="${OUTDIR:-"/.reports"}"

RUN mkdir -p "${REPODIR}" "${OUTDIR}"
COPY . "${REPODIR}"
WORKDIR "${REPODIR}"

### Run yamllint ...
RUN yamllint -f parsable . > "${OUTDIR}/yamllint.issues" || true
RUN ls -la "${OUTDIR}"

RUN echo "<<< yamllint.issues ---"; cat -v "${OUTDIR}/yamllint.issues"; echo "--- yamllint.issues >>>"
