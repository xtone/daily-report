FROM mysql:5.7

# Set debian default locale to ja_JP.UTF-8
RUN apt-get update -qq && \
    apt-get install -y locales && \
    rm -rf /var/lib/apt/lists/* && \
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

# Set MySQL character
RUN { \
    echo '[mysqld]'; \
    echo 'character-set-server = utf8'; \
    echo 'collation-server = utf8_general_ci'; \
    echo 'bind-address = 0.0.0.0'; \
    echo '[client]'; \
    echo 'default-character-set = utf8'; \
} > /etc/mysql/conf.d/charset.cnf
