```
# there isn't linux ARM v8 chrome for testing
# so can't really develop much on apple silicon - if you build linux/arm64
# qemu can't emulate chrome right
docker build --platform=linux/amd64 . -t joshuarli98/archivebox:latest

docker run -it --entrypoint /bin/bash -v "$PWD/data":/data -p 8000:8000 joshuarli98/archivebox:latest-arm64
dive joshuarli98/archivebox:latest-arm64

podman --runtime /usr/bin/crun run -it -v "$PWD/archivebox-data":/data -p 8000:8000 docker.io/joshuarli98/archivebox:latest manage createsuperuser --username admin

podman --runtime /usr/bin/crun run -v "$PWD/archivebox-data":/data -p 8000:8000 docker.io/joshuarli98/archivebox:latest init

podman --runtime /usr/bin/crun run -d -v "$PWD/archivebox-data":/data -p 8000:8000 docker.io/joshuarli98/archivebox:latest server --quick-init

podman exec --user=archivebox goofy_fermat archivebox ...
```

## changes

- slimmed down
- uses Chrome for Testing https://developer.chrome.com/blog/chrome-for-testing


## todo

- regenerate package-lock
- ublock origin
- profile why startup is so slow
  - tbh probably all those uncached calls to bin_path
