## INSTALL AŞAMASI

sunucuya girmek için.

```
ssh -i "indirdiğiniz pem" ubuntu@"sunucu public IP adresiniz"
```

sunucuya girdikten sonra 

```
sudo su -

curl https://raw.githubusercontent.com/hamidgokce/COURSE-PROJECTS--AWS-DEVOPS/main/DevOps/Wordpress_installation/docker-install_ubuntu2204.sh | bash -

git clone https://github.com/alperen-selcuk/wordpress-bitnami.git

cd wordpress-bitnami

docker compose up -d 
```


Available environment variables:

#### User and Site configuration

- `NGINX_HTTP_PORT_NUMBER`: Port used by NGINX for HTTP. Default: **8080**
- `NGINX_HTTPS_PORT_NUMBER`: Port used by NGINX for HTTPS. Default: **8443**
- `NGINX_ENABLE_ABSOLUTE_REDIRECT`: Use absolute URLs in Location header in redirections. Default: **no**
- `NGINX_ENABLE_PORT_IN_REDIRECT`: Use listening port in redirections issued by NGINX. Default: **no**
- `WORDPRESS_USERNAME`: WordPress application username. Default: **user**
- `WORDPRESS_PASSWORD`: WordPress application password. Default: **bitnami**
- `WORDPRESS_EMAIL`: WordPress application email. Default: **user@example.com**
- `WORDPRESS_FIRST_NAME`: WordPress user first name. Default: **FirstName**
- `WORDPRESS_LAST_NAME`: WordPress user last name. Default: **LastName**
- `WORDPRESS_BLOG_NAME`: WordPress blog name. Default: **User's blog**
- `WORDPRESS_DATA_TO_PERSIST`: Space separated list of files and directories to persist. Use a space to persist no data: `" "`. Default: **"wp-config.php wp-content"**
- `WORDPRESS_RESET_DATA_PERMISSIONS`: Force resetting ownership/permissions on persisted data when restarting WordPress, otherwise it assumes the ownership/permissions are correct. Ignored when running WP as non-root. Default: **no**
- `WORDPRESS_TABLE_PREFIX`: Table prefix to use in WordPress. Default: **wp_**
- `WORDPRESS_PLUGINS`: List of WordPress plugins to install and activate, separated via commas. Can also be set to `all` to activate all currently installed plugins, or `none` to skip. Default: **none**
- `WORDPRESS_EXTRA_INSTALL_ARGS`: Extra flags to append to the WordPress 'wp core install' command call. No defaults.
- `WORDPRESS_EXTRA_CLI_ARGS`: Extra flags to append to all WP-CLI command calls. No defaults.
- `WORDPRESS_EXTRA_WP_CONFIG_CONTENT`: Extra configuration to append to wp-config.php during install. No defaults.
- `WORDPRESS_ENABLE_HTTPS`: Whether to use HTTPS by default. Default: **no**
- `WORDPRESS_SKIP_BOOTSTRAP`: Skip the WordPress installation wizard. This is necessary when providing a database with existing WordPress data. Default: **no**
- `WORDPRESS_AUTO_UPDATE_LEVEL`: Level of auto-updates to allow for the WordPress core installation. Valid values: `major`, `minor`, `none`. Default: **none**
- `WORDPRESS_ENABLE_REVERSE_PROXY`: Enable WordPress support for reverse proxy headers. Default: **no**
