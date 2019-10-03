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

curl -X POST -H "Backend: 127.0.0.1:81" -H "Folder: 2019-08-29" -H "Host: file-storage.loc" -H "Content-Disposition: attachment" -H "X-Session-ID: 111.txt" --data-binary @./111.txt "http://192.168.1.2/upload/"
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
Content-Disposition: attachment
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
### Upload in "sync" mode
request:
```
POST /upload-sync HTTP/1.1
User-Agent: GuzzleHttp/6.3.3 curl/7.29.0 PHP/7.3.9
Host: file-storage.loc
Folder: 2019-10-02
X-Session-ID: 8671dc99d008.txt
X-FileId: 87
Content-Disposition: attachment
Content-Type: text/xml
Accept: */*
Content-Length: 1112
 
<?xml version="1.0" encoding="UTF-8"?>
```
response:
```
HTTP/1.1 200 OK
Server: nginx
Date: Wed, 02 Oct 2019 06:59:06 GMT
Content-Type: application/octet-stream
Content-Length: 0
Connection: keep-alive
Filename:  8671dc99d008.txt
Storage: s1.filestorage.loc
Folder: 2019-10-02
CRC32: 43bec48b
```





