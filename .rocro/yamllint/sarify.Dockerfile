FROM golang:1.15-alpine AS sarify-stage

ENV GOBIN="$GOROOT/bin" \
    GOPATH="/.go" \
    PATH="${GOPATH}/bin:/usr/local/go/bin:$PATH"

ENV REPOPATH="github.com/tetrafolium/brakeman" \
    TOOLPATH="github.com/tetrafolium/inspecode-tasks"
ENV REPODIR="${GOPATH}/src/${REPOPATH}" \
    TOOLDIR="${GOPATH}/src/${TOOLPATH}"

ENV OUTDIR="/.reports"
ENV OUTFILE="${OUTDIR}/yamllint.sarif"

RUN mkdir -p "${REPODIR}" "${OUTDIR}"
COPY . "${REPODIR}"
WORKDIR "${REPODIR}"

ENV INDIR=".rocro/.artifacts/yamllint"
ENV INFILE="${INDIR}/yamllint.issues"
ENV VERSION="$(cat "${INDIR}/yamllint.version")"
RUN ls -l "${INDIR}"

### Put symlink refers submodule-path at origin-path
RUN ln -s "${REPODIR}/$(basename "${TOOLPATH}")" "${TOOLDIR}"

### Convert yamllint issues to SARIF ...
RUN GO111MODULE="off" \
    go run "${TOOLDIR}/yamllint/cmd/main.go" -v "${VERSION}" "${REPOPATH}" \
        < "${INFILE}" > "${OUTFILE}"
RUN ls -l "${INFILE}" "${OUTFILE}"
