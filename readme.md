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
### Using secure link module for defend links
nginx config:
```
   location ~ ^/download/(?<secured_stuff>.+)/(?<secure>[\w-]+,\d+)$ {             

                                                                 
        secure_link     $secure; # in this case = "MD5_HASH,timestamp"                                                   
        secure_link_md5      PASSWORD$secure_link_expires$secured_stuff;          
        if ($secure_link = "") { return 403; } # invalid link    
        if ($secure_link = 0) { return 410; } # expired link                        
                                                                                    
        rewrite ^ /download/$secured_stuff;                      
    }                                                                               
                                                                                    
    location /download/ {                                                           
        internal;                                                      
        alias /var/upload/;                                                         
    } 

```
generate md5 with openssl
```
echo -n 'PASSWORD21474836472019-05-12/111.txt' | openssl md5 -binary | openssl base64 | tr +/ -_ | tr -d =
```
Example download 
```
wget http://file-storage.loc/download/2019-05-12/111.txt/89VaJ0KNogCUd1Ch3AmfRQ,2147483647
```
Test uploading files
vim /root/test.sh:
```
#/bin/bash
for i in `seq 1 1000`
        do
                >/root/test.txt;
                for i in `seq 1 100`
                        do
                                head /dev/urandom | tr -dc A-Za-z0-9 | head -c 15 >> /root/test.txt
                        done
                t_dir=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 15)
                t_name=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 50)
                curl -i -X POST -H "Folder: 11/$t_dir" -H "X-Session-ID: $t_name.txt" -H "Host: file-storage.loc" -H "Content-Disposition: attachment" --data-binary @/root/test.txt "http://192.168.1.2/upload-sync"
        done

```
chmod +x /root/test.sh


