### Compiling nginx with nginx-upload-module for file server

1. https://github.com/iymaltsev/nginx-upload-module
2. https://www.yanxurui.cc/posts/server/2017-03-21-NGINX-as-a-file-server/#nginx-upload-module

### on Host machine:

```
/etc/hosts:
192.168.1.2 file-storage.loc

cd ./nginx-upload-with-progress-modules/
docker build -t nginx_image .
docker run -d -v /webroot:/var/www/html -p 80:80 --name nginx_upload nginx_image
echo "123" >> 111.txt

curl -X POST -H "Folder: 2019-08-29" -H "Host: file-storage.loc" -H "Content-Disposition: attachment, filename=\"111.txt\"" -H "X-Session-ID: 111.txt" --data-binary @./111.txt "http://192.168.1.2/upload/"
```

### in same time nginx-upload-module will send file metadata to "backend":

```
POST /upload/ HTTP/1.0
Host: 127.0.0.1:81
Connection: close
Content-Length: 578
User-Agent: curl/7.58.0
Accept: */*
Folder: 2019-08-29
Content-Disposition: attachment, filename="111.txt"
X-Session-ID: 111.txt
Content-Type: multipart/form-data; boundary=00000000000000000012

--00000000000000000012
Content-Disposition: form-data; name=".name"

111.txt
--00000000000000000012
Content-Disposition: form-data; name=".content_type"

application/x-www-form-urlencoded
--00000000000000000012
Content-Disposition: form-data; name=".path"

/var/upload/2019-08-29/111.txt
--00000000000000000012
Content-Disposition: form-data; name=".crc32"

40c11657
--00000000000000000012
Content-Disposition: form-data; name=".size"

13
--00000000000000000012
Content-Disposition: form-data; name=".storage"

file-storage.loc
--00000000000000000012--
```

### enter to container and try to download file:

```
docker ps
docker exec -it b13cf72be58a sh
wget http://127.0.0.1:81/download/2019-08-29/111.txt
```
