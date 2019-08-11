#------------------------------------------------------------------------------
# CREATE /etc/docker-meta.yml
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
RUN echo >>/etc/docker-meta.yml "- name: ${NAME}" \
    && echo >>/etc/docker-meta.yml "  version: ${VERSION}" \
    && echo >>/etc/docker-meta.yml "  commit: ${COMMIT}" \
    && echo >>/etc/docker-meta.yml "  url: ${URL}" \
    && echo >>/etc/docker-meta.yml "  branch: ${BRANCH}" \
    && echo >>/etc/docker-meta.yml "  date: ${DATE}" \
    && echo >>/etc/docker-meta.yml "  repo: ${REPO}" \
    && echo >>/etc/docker-meta.yml "  docker_tag: ${DOCKER_TAG}" \
    && echo >>/etc/docker-meta.yml "  dockerfile_path: ${DOCKERFILE_PATH}" \
    && echo >>/etc/docker-meta.yml "  dockerfile: |" \
    && sed >>/etc/docker-meta.yml 's/^/    /' </provision/"${DOCKERFILE_PATH}" \
    && rm -r /provision
# END CREATE /etc/docker-meta.yml
#------------------------------------------------------------------------------

FROM stefco/llama-base:deb-0.6.4
ARG DOCKER_TAG

#------------------------------------------------------------------------------
# APPEND /etc/docker-meta.yml
COPY --from=meta /etc/docker-meta.yml /etc/new-docker-meta.yml
RUN cat /etc/new-docker-meta.yml >>/etc/docker-meta.yml \
    && echo New metadata: \
    && cat /etc/docker-meta.yml \
    && rm /etc/new-docker-meta.yml
# END APPEND /etc/docker-meta.yml
#------------------------------------------------------------------------------

COPY . /root/provision

# install extra packages and conda packages
RUN mkdir -p ~/.local/share ~/.cache ~/.jupyter \
    && cp -R ~/provision/static/nbconfig ~/.jupyter/nbconfig \
    && conda install -y --file ~/provision/conda.txt \
    && pip install -r ~/provision/requirements.txt \
    && rm -r /opt/anaconda/pkgs \
    && jt \
        -t oceans16 \
        -cellw 80% \
        -lineh 170 \
        -altp -T \
        -vim \
        -f iosevka \
    && jupyter labextension install \
        @jupyter-widgets/jupyterlab-manager \
        ipytree \
        @jupyterlab/toc \
        jupyterlab-drawio \
        @krassowski/jupyterlab_go_to_definition \
        @ryantam626/jupyterlab_code_formatter \
    && rm -rf /root/provision

WORKDIR /root
