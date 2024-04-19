FROM ubuntu:jammy

RUN apt update && \
    apt install \
        -y \
        --no-install-suggests \
        --no-install-recommends \
        'curl' 'git' 'python3-pip' 'xz-utils' && \
    python3 -m pip install pip -U

RUN pip install \
        --disable-pip-version-check \
        --no-cache-dir \
        --force-reinstall \
        'https://github.com/s3tools/s3cmd/archive/9d17075b77e933cf9d7916435c426d38ab5bca5e.zip'

RUN curl -L 'https://aka.ms/InstallAzureCLIDeb' | bash

# python - Can I force pip to make a shallow checkout when installing from git? - Stack Overflow
#   https://stackoverflow.com/a/52989760
RUN pip install \
        --disable-pip-version-check \
        --no-cache-dir \
        --force-reinstall \
        'https://github.com/streamlink/streamlink/archive/abf230fe69c373c262fff69797e946fb03a21e15.zip'

RUN pip install \
        --disable-pip-version-check \
        --no-cache-dir \
        --force-reinstall \
        'https://github.com/yt-dlp/yt-dlp/archive/168e72dcd3e04e0e19e92c012a04b8a1e4658f50.zip'

# git - How to shallow clone a specific commit with depth 1? - Stack Overflow
#   https://stackoverflow.com/a/43136160
RUN mkdir '/SL-plugins' && \
    git -C '/SL-plugins' init && \
    git -C '/SL-plugins' remote add 'origin' 'https://github.com/code-with-IPID/streamlink-plugins.git' && \
    git -C '/SL-plugins' fetch --depth=1 'origin' '539a2ab614ffc53b60101bd2522f197b544b10b9' && \
    git -C '/SL-plugins' switch --detach 'FETCH_HEAD'

RUN mkdir '/opt/ffmpeg' && \
    curl -L 'https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2024-04-19-12-56/ffmpeg-n7.0-12-gcbd98447bc-linux64-gpl-7.0.tar.xz' | \
        tar -C '/opt/ffmpeg' -f- -x --xz --strip-components=1

ENV PATH="/opt/ffmpeg/bin:${PATH}"

VOLUME [ "/SL-downloads" ]

# for cookies.txt
RUN mkdir '/YTDLP'

COPY --chown=0:0 --chmod=700 ./script.sh /script.sh

ENTRYPOINT [ "/script.sh" ]
