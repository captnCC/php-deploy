FROM php:7.1-cli

# Install our basic tools ssh & rsync
RUN apt-get update -yqq && apt-get install -y openssh-client bash rsync git libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev zlib1g

# Disable host key checking for ssh
RUN mkdir /root/.ssh
COPY config /root/.ssh/config

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"\
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/bin --filename=composer \
  && docker-php-ext-install -j$(nproc) iconv mcrypt \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd
  && docker-php-ext-install mbstring zip \
  && docker-php-ext-enable mbstring zip
