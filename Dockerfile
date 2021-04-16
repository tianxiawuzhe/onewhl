FROM alpine:3.12

ENV ALPINE_VERSION=3.12
ENV TIMEZONE=Asia/Shanghai

COPY ./Dockerfile  /
#COPY Shanghai /etc/localtime

# These packages are not installed immediately, but are added at runtime or ONBUILD to shrink the image as much as possible. Notes:
#   * build-base: used so we include the basic development packages (gcc)
#   * linux-headers: commonly needed, and an unusual package name from Alpine.
#   * python3-dev: are used for gevent e.g.
ENV BUILD_PACKAGES="\
  build-base \
  linux-headers \
  python3-dev \
  openblas \
  openblas-dev \
  lapack \
  lapack-dev \
  blas \
  blas-dev \
"

## running
RUN echo "Begin" \
##  && GITHUB_URL='https://github.com/tianxiawuzhe/chgcheck_alpine312_py385_django312/raw/master' \
##  && wget -O Dockerfile --timeout=30 -t 5 "${GITHUB_URL}/Dockerfile" \
##  && wget -O entrypoint.sh --timeout=30 -t 5 "${GITHUB_URL}/entrypoint.sh" \
  && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && echo "********** 安装临时依赖" \
  && apk add --no-cache --virtual=.build-deps $BUILD_PACKAGES \
  && echo "********** 更新python信息" \
  && { [[ -e /usr/bin/python ]] || ln -sf /usr/bin/python3.8 /usr/bin/python; } \
  && python -m ensurepip \
  && python -m pip install --upgrade --no-cache-dir pip \
  && cd /usr/bin \
  && ls -l python* pip* \
  && echo "********** 安装python包" \
  && speed="-i http://mirrors.aliyun.com/pypi/simple  --trusted-host mirrors.aliyun.com" \
  && pip install --no-cache-dir wheel ${speed} \
  && mkdir /whl && cd /whl \
  && pip wheel pandas==1.2.3 ${speed} \
  && echo "End"

CMD ["tail", "-f", "/dev/null"]
