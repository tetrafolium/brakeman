FROM python:alpine AS linter-stage

### Install yamllint tool ...
RUN pip3 install --no-cache-dir 'yamllint>=1.24.0,<1.25.0' && \
    echo "+++ $(yamllint --version)"

ENV REPOPATH="github.com/tetrafolium/brakeman"
ENV REPODIR="${GOPATH}/src/${REPOPATH}"

ARG OUTDIR
ENV OUTDIR="${OUTDIR:-"/.reports"}"
ENV OUTFILE="${OUTDIR}/yamllint.issues" \
    VERSIONFILE="${OUTDIR}/yamllint.version"

RUN mkdir -p "${REPODIR}" "${OUTDIR}"
COPY . "${REPODIR}"
WORKDIR "${REPODIR}"

### Run yamllint ...
RUN yamllint --version > "${VERSIONFILE}" && \
    ( yamllint -f parsable . > "${OUTFILE}" || true ) && \
    ls -la "${OUTDIR}" && \
    ( echo "<<< ${OUTFILE} ---"; cat -n "${OUTFILE}"; echo "--- ${OUTFILE} >>>" )
