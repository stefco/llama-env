#==============================================================================
# CREATE meta
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
# END CREATE meta
#==============================================================================

#==============================================================================
# CREATE llama-env
FROM stefco/llama-base:deb-0.12.3 AS llama-env
ARG DOCKER_TAG
ARG PYTHON_MINOR

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
    && cat >~/provision/CONDA.txt \
        ~/provision/conda-base.txt  \
        ~/provision/conda.txt \
        ~/provision/conda-linux.txt \
    && echo "Contents of ~/provision/CONDA.txt to be installed:" \
    && cat ~/provision/CONDA.txt \
    && conda install -y --file ~/provision/CONDA.txt \
    && echo "Contents of ~/provision/requirements.txt to be installed:" \
    && cat ~/provision/requirements.txt \
    && pip install -r ~/provision/requirements.txt \
    && echo "Running python tests" \
    && echo "Python version: `which python`" \
    && python ~/provision/tests.py \
    && conda clean -y --all \
    && rm -rf /root/provision

WORKDIR /root
# END CREATE llama-env
#==============================================================================

#==============================================================================
# CREATE llama-env-ipy
FROM llama-env-intermediate AS llama-env-ipy

RUN echo "Making llama-env-ipy" \
    && echo "Contents of ~/provision/conda-ipy.txt to be installed:" \
    && cat ~/provision/conda-ipy.txt \
    && conda install -y --file ~/provision/conda-ipy.txt \
    && echo "Contents of ~/provision/requirements-ipy.txt to be installed:" \
    && cat ~/provision/requirements-ipy.txt \
    && pip install -r ~/provision/requirements-ipy.txt \
    && conda clean -y --all \
    && ipython profile create default \
    && cat ~/provision/static/ipython_config.py \
        >>~/.ipython/profile_default/ipython_config.py \
    && rm -rf /root/provision
# END CREATE llama-env-ipy
#==============================================================================
