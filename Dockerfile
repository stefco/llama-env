#------------------------------------------------------------------------------
# CREATE docker-meta.yml
ARG DOCKER_TAG
ARG NAME
ARG VERSION
ARG COMMIT
ARG URL
ARG BRANCH
ARG DATE
ARG REPO
ARG DOCKERFILE_PATH
FROM alpine AS meta
COPY "${DOCKERFILE_PATH}" /provision
RUN echo >>/docker-meta.yml "- name: ${NAME}" \
    && echo >>/docker-meta.yml "  version: ${VERSION}" \
    && echo >>/docker-meta.yml "  commit: ${COMMIT}" \
    && echo >>/docker-meta.yml "  url: ${URL}" \
    && echo >>/docker-meta.yml "  branch: ${BRANCH}" \
    && echo >>/docker-meta.yml "  date: ${DATE}" \
    && echo >>/docker-meta.yml "  repo: ${REPO}" \
    && echo >>/docker-meta.yml "  docker_tag: ${DOCKER_TAG}" \
    && echo >>/docker-meta.yml "  dockerfile_path: ${DOCKERFILE_PATH}" \
    && echo >>/docker-meta.yml "  dockerfile: |" \
    && sed >>/docker-meta.yml 's/^/    /' </provision/"${DOCKERFILE_PATH}" \
    && rm -r /provision
# END CREATE docker-meta.yml
#------------------------------------------------------------------------------

FROM stefco/llama-base:alpine

#------------------------------------------------------------------------------
# APPEND docker-meta.yml
COPY --from=meta /docker-meta.yml /new-docker-meta.yml
RUN cat /new-docker-meta.yml >>/docker-meta.yml && rm /new-docker-meta.yml
# END APPEND docker-meta.yml
#------------------------------------------------------------------------------

COPY . /home/llama/provision

# install git-lfs and conda
RUN su llama -c "bash -i -c ' \
    cd ~ \
        && type conda \
        && conda env create -f ~/provision/llama-${DOCKER_TAG}.yml \
        && echo conda\ activate\ llama-${DOCKER_TAG}\ >>~/.bashrc \
        && cat ~/.bashrc \
        && source ~/.bashrc \
        && pip install -r ~/provision/requirements.txt \
        && rm -r ~/miniconda3/pkgs \
'" \
    && apk --no-cache add git openssh graphviz font-bitstream-type1 \
    && rm -rf /home/llama/provision
USER llama
WORKDIR /home/llama
