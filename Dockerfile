FROM php:8.2-fpm

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
	git \
	unzip \
	&& docker-php-ext-install pdo_mysql

# Composerのインストール
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ワーキングディレクトリの設定
WORKDIR /var/www/html

# Composerパッケージのインストール
COPY composer.json composer.json
COPY composer.lock composer.lock
RUN composer install --no-scripts --no-autoloader

# アプリケーションのコードをコピー
COPY . .

# Composerオートロードとキャッシュの再構築
RUN composer dump-autoload

# コンテナの起動時にLaravelのキャッシュをクリア
RUN php artisan optimize:clear

# ポートの公開
EXPOSE 8000

# PHP内蔵のWebサーバーを起動
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
