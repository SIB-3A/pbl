# Cara run

1. install php,laravel,mysql,phpmyadmin versi terbaru
2. fork dan clone repo ini
3. create database baru
4. copy .env.example dan rename jadi .env

5. ubah env database menjadi dibawah
```env
// ganti yg didalam <...>
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=<nama_db>
DB_USERNAME=<username_db>
DB_PASSWORD=<password_db>
```
6. ubah env: `SESSION_DRIVER=file`
7. run projectnya
 