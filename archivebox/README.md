docker build . -t archivebox
docker run -v "$PWD/data":/data archivebox init
docker run -v "$PWD/data":/data -it archivebox manage createsuperuser
docker run -v "$PWD/data":/data -p 8000:8000 archivebox server
