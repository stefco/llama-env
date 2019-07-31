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
ARG DOCKER_TAG
ARG NAME
ARG VERSION
ARG COMMIT
ARG URL
ARG BRANCH
ARG DATE
ARG REPO
ARG DOCKERFILE_PATH
COPY "${DOCKERFILE_PATH}" /provision/"${DOCKERFILE_PATH}"
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

FROM stefco/llama-base:deb-datagrid
ARG DOCKER_TAG

#------------------------------------------------------------------------------
# APPEND docker-meta.yml
COPY --from=meta /docker-meta.yml /new-docker-meta.yml
RUN cat /new-docker-meta.yml >>/docker-meta.yml \
    && echo New metadata: \
    && cat /docker-meta.yml \
    && rm /new-docker-meta.yml
# END APPEND docker-meta.yml
#------------------------------------------------------------------------------

COPY . /home/llama/provision

# install extra packages and conda
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends vim git graphviz \
    && rm -rf /var/lib/apt/lists/*
RUN su llama -c "bash -i -c ' \
    cd ~ \
        && echo Docker tag: ${DOCKER_TAG} \
        && sed s/{DOCKER_TAG}/${DOCKER_TAG}/ ~/provision/llama-env.yml \
            | sed s/{PYTHON_MINOR}/`printf '%s' ${DOCKER_TAG} | tail -c1`/ \
                >~/llama-${DOCKER_TAG}.yml \
        && if [[ $DOCKER_TAG == *heavy* ]]; then \
                echo CONDA HEAVY SELECTED, UNCOMMENTING OPTIONAL LIGO DEPS; \
                sed -i.orig "'"'"s/^  # -/  -/"'"'" \
                    ~/llama-${DOCKER_TAG}.yml; \
            else \
                echo NOT USING CONDA HEAVY; \
            fi \
        && cat ~/llama-${DOCKER_TAG}.yml \
        && type conda \
        && conda env create -f ~/llama-${DOCKER_TAG}.yml \
        && rm ~/llama-${DOCKER_TAG}.yml \
        && echo conda\ activate\ llama-${DOCKER_TAG}\ >>~/.bashrc \
        && cat ~/.bashrc \
        && source ~/.bashrc \
        && pip install -r ~/provision/requirements.txt \
        && rm -r ~/miniconda3/pkgs \
'" \
    && rm -rf /home/llama/provision
USER llama
WORKDIR /home/llama
