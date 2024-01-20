docker build --platform=linux/amd64 . -t joshuarli98/archivebox:latest

podman --runtime /usr/bin/crun run -it -v "$PWD/archivebox-data":/data -p 8000:8000 docker.io/joshuarli98/archivebox:latest manage createsuperuser --username admin

podman --runtime /usr/bin/crun run -v "$PWD/archivebox-data":/data -p 8000:8000 docker.io/joshuarli98/archivebox:latest init

podman --runtime /usr/bin/crun run -d -v "$PWD/archivebox-data":/data -p 8000:8000 docker.io/joshuarli98/archivebox:latest server --quick-init

podman exec --user=archivebox goofy_fermat archivebox ...


## todo

- regenerate package-lock
- disable wget if size is too big
- chromium direct install without playwright?
- ublock origin
- profile why startup is so slow
