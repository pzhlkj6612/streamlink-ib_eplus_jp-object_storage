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
        'https://github.com/streamlink/streamlink/archive/a25de3b26d0f35103811e104c82e8b9eeadb4555.zip'

RUN pip install \
        --disable-pip-version-check \
        --no-cache-dir \
        --force-reinstall \
        'https://github.com/yt-dlp/yt-dlp/archive/a065086640e888e8d58c615d52ed2f4f4e4c9d18.zip'

# git - How to shallow clone a specific commit with depth 1? - Stack Overflow
#   https://stackoverflow.com/a/43136160
RUN mkdir '/SL-plugins' && \
    git -C '/SL-plugins' init && \
    git -C '/SL-plugins' remote add 'origin' 'https://github.com/pmrowla/streamlink-plugins.git' && \
    git -C '/SL-plugins' fetch --depth=1 'origin' 'fa794c0bd23a6439be9ec313ed71b4050339c752' && \
    git -C '/SL-plugins' switch --detach 'FETCH_HEAD'

RUN mkdir '/opt/ffmpeg' && \
    if [ "$(uname -m)" = 'x86_64' ]; then \
        ffmpeg_url='https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2024-08-16-13-46/ffmpeg-n7.0.2-5-g5ff181c025-linux64-gpl-7.0.tar.xz'; \
    else \
        ffmpeg_url='https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2024-08-16-13-46/ffmpeg-n7.0.2-5-g5ff181c025-linuxarm64-gpl-7.0.tar.xz'; \
    fi && \
    curl -L "${ffmpeg_url}" | \
        tar -C '/opt/ffmpeg' -f- -x --xz --strip-components=1

ENV PATH="/opt/ffmpeg/bin:${PATH}"

VOLUME [ "/SL-downloads" ]

# for cookies.txt
RUN mkdir '/YTDLP'

COPY --chown=0:0 --chmod=700 ./script.sh /script.sh

ENTRYPOINT [ "/script.sh" ]
