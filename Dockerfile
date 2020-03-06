FROM python:3.8

RUN set -ex \
    ; pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    ; pip install --no-cache-dir mkdocs mkdocs-material pygments \
    ; mkdir -p /mkdocs

WORKDIR /mkdocs
EXPOSE 80

CMD [ "mkdocs", "serve", "-a", "0.0.0.0:80" ]