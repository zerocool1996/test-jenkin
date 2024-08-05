# Sử dụng Ubuntu 20.04 làm base image
FROM ubuntu:20.04

# Cập nhật các gói và cài đặt các phần mềm cần thiết
RUN apt-get update && \
    apt-get install -y nginx ca-certificates apt-transport-https software-properties-common curl unzip nano && \
    add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -y php8.2 php8.2-fpm php8.2-cli php8.2-common php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath

# Cài đặt Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Sao chép cấu hình nginx
COPY ./docker/nginx.conf /etc/nginx/sites-available/default

# Thiết lập thư mục làm việc
WORKDIR /var/www/html/app

# Sao chép mã nguồn Laravel vào container
COPY . /var/www/html/app

# Cài đặt các dependencies của Laravel bằng Composer
RUN composer install --no-interaction --no-plugins --no-scripts

# Thiết lập quyền truy cập cho thư mục storage và bootstrap/cache
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Mở cổng 80
EXPOSE 80

# Khởi động nginx và PHP FPM khi container được chạy
CMD ["nginx", "-g", "daemon off;"]
# CMD ["php", "artisan", "serve", "--host", "0.0.0.0", "--port", "80"]
