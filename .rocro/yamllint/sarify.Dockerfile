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

ENV INFILE=".rocro/yamllint/yamllint.issues"
RUN ls -l "${INFILE}"
RUN cat -n "${INFILE}"

### Put symlink refers submodule-path at origin-path
RUN ln -s "${REPODIR}/$(basename "${TOOLPATH}")" "${TOOLDIR}"

### Convert yamllint issues to SARIF ...
RUN GO111MODULE="off" \
    go run "${TOOLDIR}/yamllint/cmd/main.go" "${REPOPATH}" \
        < "${INFILE}" > "${OUTFILE}"
RUN ls -l "${INFILE}" "${OUTFILE}"
