# Init script for VVV Auto Site Setup
source site-vars.sh
echo "Commencing $site_name Site Setup"

# Make a database, if we don't already have one
echo "Creating $site_name database (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS $database"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON $database.* TO $dbuser@localhost IDENTIFIED BY '$dbpass';"

# Install WordPress if it's not already present.
if [[ ! -d "htdocs/wp-admin" ]]
	then

	echo "Installing WordPress"
	if [ ! -d "./htdocs" ]; then
		mkdir ./htdocs
	fi
	cd ./htdocs

	# Move into htdocs to run 'wp' commands.
	wp core download --locale=en_US --allow-root
	wp core config --dbname="$database" --dbuser="$dbuser" --dbpass="$dbpass" --dbhost="localhost" --dbprefix="$prefix" --locale=en_US --allow-root --extra-php <<PHP
/* Cache Salt */
define( 'WP_CACHE_KEY_SALT', '$salt_key' );

/* Debug */
define( 'WP_DEBUG' , true );
define( 'WP_DEBUG_DISPLAY' , false );
define( 'WP_DEBUG_LOG' , true );
define( 'SCRIPT_DEBUG' , true );
define( 'SAVEQUERIES' , true );
define( 'WP_ENV' , 'development' );
define( 'JETPACK_DEV_DEBUG' , true );
PHP
	wp core install --url="$domain" --title="$site_name" --admin_user="$admin_user" --admin_password="$admin_pass" --admin_email="$admin_email" --allow-root

	#Install all WordPress.org plugins in the org_plugins file using CLI
	echo "Installing WordPress.org Plugins"
	for pkg in "${wordpress_plugins[@]}"; do
		wp plugin install $pkg --activate --allow-root
	done

	# Install latest version of roots and soil, activate it
	echo "Installing Sage Theme"
	git clone https://github.com/roots/sage.git src/themes/sage

	echo "Installing Soil Plugin"
	git clone https://github.com/roots/soil.git src/plugins/soil
	wp plugin activate soil --allow-root
	cd -

fi
# Symlink working directories
# First clear out any links already present
find htdocs/wp-content/ -maxdepth 2 -type l -exec rm -f {} \;
# Next attach symlinks for eacy of our types.

# Plugins
echo "Linking working directory plugins"
find src/plugins/ -maxdepth 1 -mindepth 1 -type d -exec ln -s $PWD/{} $PWD/htdocs/wp-content/plugins/ \;

# Themes
echo "Linking working directory themes"
find src/themes/ -maxdepth 1 -mindepth 1 -type d -exec ln -s $PWD/{} $PWD/htdocs/wp-content/themes/ \;


# The Vagrant site setup script will restart Nginx for us
echo "$site_name is now set up!";