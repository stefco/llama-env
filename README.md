# Low-Latency Algorith for Multi-messenger Astrophysics (LLAMA) Conda build environment
![Anaconda environment used](https://anaconda.org/stefco/llama-py37/badges/version.svg)

[LLAMA](http://multimessenger.science) is a reliable and flexible multi-messenger astrophysics framework and search pipeline. It identifies astrophysical signals by combining observations from multiple types of astrophysical messengers and can either be run in online mode as a self-contained low-latency pipeline or in offline mode for post-hoc analyses. It is maintained by [Stefan Countryman](https://stc.sh) from [this github repository](https://github.com/stefco/llama-env); the Docker image can be found [here](https://cloud.docker.com/repository/registry-1.docker.io/stefco/llama-env). Some
documentation on manually pushing the [Conda environment](https://anaconda.org/stefco/environments) is available
[here](http://docs.anaconda.com/anaconda-cloud/user-guide/tasks/work-with-environments/).

This image serves as a build environment for LLAMA code. It has an Anaconda python distribution with all LLAMA dependencies installed for user `llama`.
