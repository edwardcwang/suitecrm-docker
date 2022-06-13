A simple Dockerfile for SuiteCRM.

It exposes a non-HTTPS port at port 80. You can use caddy/nginx/etc to provide SSL termination if needed.

# Usage

1. Build the Dockerfile: `docker build -t suitecrm-docker .`
2. Launch the container with the following variables.

* `SUITECRM_DB_NAME` - database name to use
* `SUITECRM_DB_HOSTNAME` - MySQL database hostname
* `SUITECRM_DB_USERNAME` - MySQL database connection username
* `SUITECRM_DB_PASSWORD` - MySQL database connection password
* `SUITECRM_HOST_NAME` - Host name for the instance
* `SUITECRM_SITE_URL` - something like `//myhostname.example.com/`

# Install

Ensure that the MySQL database named in `SUITECRM_DB_NAME` does not already exist.

1. Run the container as normal, but then use `docker exec -u 0 -it container_name bash` to enter into the container.
2. Temporarily remove `/var/www/html/config.php` to allow the install to work.
3. (Alternative, not working at the moment) Edit `/var/www/html/config.php` and edit `'installer_locked' => true` to false. Then `chmod a+w /var/www/html/config.php`
4. Go to http://your_container_ip/install.php and complete the install. You will need to re-fill in some of the variables above manually.
5. Remove and re-start the container to restore the default `config.php`.

# Volumes to save

* `/var/www/html/upload` - file uploads
