# docker-wordpress-fpm-sendmail
a docker image of wordpress:fpm with sendmail installed so that php mail works

## Usage

Use this image(`osexp2000/wordpress-fpm-sendmail`) to replace `wordpress:fpm` in your `docker-compose.yml`

Sample `docker-compose.yml`

```
version: '2'

services:
  wordpress:
    depends_on:
      - db
    # image: wordpress:fpm
    image: osexp2000/wordpress-fpm-sendmail  #####here#####
    volumes:
      - ./wordpress:/var/www/html
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress

  db:
    image: mysql
    volumes:
      - ./db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: somewordpress
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress

  nginx:
    image: nginx
    depends_on:
      - wordpress
    ports:
      - "8000:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./ssl/crt:/etc/nginx/pki/crt
      - ./ssl/key:/etc/nginx/pki/key
      - ./wordpress:/var/www/html
    restart: always
```

-------

To use ssl in nginx, you need prepare `./nginx.conf`, e.x,

```
server {
    server_name  localhost; #Modify this please
    listen 443;

    ssl on;
    ssl_certificate     /etc/nginx/pki/crt;
    ssl_certificate_key /etc/nginx/pki/key;

    ssl_session_timeout  5m;

    ssl_protocols  SSLv2 SSLv3 TLSv1;
    ssl_ciphers  ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
    ssl_prefer_server_ciphers   on;

    location / {
        index  index.php index.html index.htm;
        root   /var/www/html;
    }

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    location ~ \.php$ {
        fastcgi_pass   wordpress:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /var/www/html/$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```

you also need use ssl tools such as openssl to generate a file at `./ssl/crt` as public key, e.x,

```
-----BEGIN CERTIFICATE-----
MIIDLjCCAhYCCQCn/NJVT1acRDANBgkqhkiG9w0BAQUFADBZMQswCQYDVQQGEwJB
VTETMBEGA1UECBMKU29tZS1TdGF0ZTEhMB8GA1UEChMYSW50ZXJuZXQgV2lkZ2l0
cyBQdHkgTHRkMRIwEAYDVQQDEwlsb2NhbGhvc3QwHhcNMTcwMTE2MDU0OTMzWhcN
MTcwMjE1MDU0OTMzWjBZMQswCQYDVQQGEwJBVTETMBEGA1UECBMKU29tZS1TdGF0
ZTEhMB8GA1UEChMYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMRIwEAYDVQQDEwls
b2NhbGhvc3QwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDAMnGhH0Yj
Y3Cbc8UwdNLAOqQV9+aktXvzt+FehuvmvwgT/LZHqn8utenyNw6sjS/qUZCY9ExX
WH/u92sjcM8Fg+AYEAQ3Zw9Pqoq6ijLkO7lw1Fk0eKx5OdpCyh3zGfdsZyHsJOc+
2imCuJpIYIz/UK/F8N13Jw88saiBlVAjZfrsC0ZJ0X0xiJoiWuFCSqGGtW8P2Eqv
xWfCq/BoTbtzLRtDIOgICdoO9gNadrahlIyTxJcCvWAUQgyEWbV+fl0+vPVs8ueb
QoXtD4rkUFQG7ik1JfHZuoPOS+RizAAtMiuphs26HGjfyFgRstUA98boIYdveXxK
WSlXFFKGlUjtAgMBAAEwDQYJKoZIhvcNAQEFBQADggEBAEaQPKxZsp18mO02XHkR
48xU+aUe3IuBVjOZpjV+Z1N+KdgTaTa4/QQFrEYMP+yuGocIg036Rlo/0YFzdXCn
QPAJ8CCM50xLiRNkyDYpmY1e6nf+e0Wuj0/A70ygg1isIMSo+J93P13U2ri7lDFV
ed5pXhJ8apaSigcgs9Pj842VwAd7ljm8FH/ULH93GLUrMNFr1iq6Vhhx5cxbkQj1
czT83kAwsv/tEMX+yIin9s9y83XNYffojoYEPTpChhqRQ3D4YIwQB7Byr5utuUS2
7UgcxAr6fRgX7xWCZS5Vchp3Hb0BTiL35+/sCKQ72+PAhyV58veRnCzzspWhtObl
LB0=
-----END CERTIFICATE-----
```

and `./ssl/key` as private key, e.x,

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAwDJxoR9GI2Nwm3PFMHTSwDqkFffmpLV787fhXobr5r8IE/y2
R6p/LrXp8jcOrI0v6lGQmPRMV1h/7vdrI3DPBYPgGBAEN2cPT6qKuooy5Du5cNRZ
NHiseTnaQsod8xn3bGch7CTnPtopgriaSGCM/1CvxfDddycPPLGogZVQI2X67AtG
SdF9MYiaIlrhQkqhhrVvD9hKr8VnwqvwaE27cy0bQyDoCAnaDvYDWna2oZSMk8SX
Ar1gFEIMhFm1fn5dPrz1bPLnm0KF7Q+K5FBUBu4pNSXx2bqDzkvkYswALTIrqYbN
uhxo38hYEbLVAPfG6CGHb3l8SlkpVxRShpVI7QIDAQABAoIBAQCbMuCw4+kmQHE5
BkZQN7XLRk8j8jfL/0TlbDHPvBGYFeB3C1VCD7p9xKXyUmVGDwiHJXAnIvbWfX9p
P1/DkZ+Ka5A0vhI5jr49bZByy5AG3veC1eZmyZ80kPPfhQikOu6iGbG5157oERD+
HwVutpCExun5Y+PiCKd0Ml3IrgK1YYjrGEaQxWqG8lYZP4589zoEwT6yHdI5vmSA
k3pZ5jos9dFkRnZc5LuaN0H6DVCaHgq983AOLgYxA9Wg+vZSY8ugNqnqPaErlMlk
nF/2l2Agt06XyOLPoO2XHjIFrCoQIcIEgUxTCFl7ism4C0FekXkLX+9WVvt1seVJ
PBr4lQf9AoGBAOJZJibw8kcpwroiWp1+jSKPJRrkWKiIfzSyTpCzDQXrX0ZOQQVA
kt3VhvopkjzEhIHKbASEC52dR2CcfkNLuLKl8OvLyAEUrr8BT3gf5J4opLIoUsSZ
ZHfllaLDwfimgdtlk9Zl9xUb+4E++zbp48WQM+VQ2tNhQLFIP/4+qeH/AoGBANlf
/rWHYPaSVMu1iSjXioPC0MU7khxRtu3UytIDkUVSPo+XtjffQ6rv24mvcTjJ6v99
wEbAtIPg2HVTgrtHsX1Rmoa17VP9fE5cfyXWIjeY5HLwF+EkW50BsD9jEumCNc0E
DiECzngeUPY2vEYh8FnEW9DsycWMq6basx/TYH0TAoGBALs+soAOXO6fzlX6q2mU
Uh7fuftIIUuyN0EZrEKpzEE0WEmp3MICjDx1Msbp8u7QRymzka4eqhlGDdEPRKhZ
EL7A5c+6cYbrXC/oXpxqDc8EolI7Z1T57BH/W80dEe6nl88udaEsEr1ku6dMubbQ
v7sksrmmLJAm6MR/l2i04AZzAoGBANMwaI6FELd+Q9QGc1Oy1WheBecZkULiQQ+g
Bc00mhb3aMCpbOerilqw3mJOiXna8u12hzA2WSsncCXNFN5PMSnH9pGafxFy3Spk
w0NHX8cUTB8/FHQwlrFbyphK8TzcvNiKcA+yYlZhXddYJmMc5h7Qn0PESeQcX0ik
ghMRklTxAoGAXjt9E6eVYpSnVFgRXgskaLN2Kh0ipYVYhOhpEfcQuWPPNeG0mVaV
Spx5lyZ0lKHxlHy0k9XrX3AqgAxoa6l30Aemhbp2PinLB9BkNsuH8F8d9cSaaIzG
P0CIqVXkDOyD6LpiN73acNeRAmmXyQHvIM6yETUa9e1nWPG7mXqMeEY=
-----END RSA PRIVATE KEY-----
```
