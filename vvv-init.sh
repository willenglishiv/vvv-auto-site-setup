# Init script for VVV Auto Site Setup
source config/site-vars.sh
echo "Commencing $site_name Site Setup"

# Make a database, if we don't already have one
echo "Creating $site_name database (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS $database"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON $database.* TO $dbuser@localhost IDENTIFIED BY '$dbpass';"

# Install WordPress if it's not already present.
if [[ ! -d htdocs ]]
	then
	# Behind Firewall/Proxy
	# git config url.https://github.com/.insteadOf git://github.com/

	echo "Installing WordPress using WP-CLI"
	mkdir htdocs

	# Move into htdocs to run 'wp' commands.
	wp core download
	wp core config --dbname="$database" --dbuser="$dbuser" --dbpass="$dbpass" --extra-php <<PHP
/* Cache Salt */
define( 'WP_CACHE_KEY_SALT', '$salt_key' );

/* Debug */
define( 'WP_DEBUG', true );
define( 'SCRIPT_DEBUG', true );
define( 'SAVEQUERIES', true );
define( 'WP_ENV' , 'development');
define( 'JETPACK_DEV_DEBUG', true);
PHP
	wp core install --url="$domain" --title="$site_name" --admin_user="$admin_user" --admin_password="$admin_pass" --admin_email="$admin_email"

	#Install all WordPress.org plugins in the org_plugins file using CLI
	echo "Installing WordPress.org Plugins"
	for pkg in "${wordpress_plugins[@]}"; do
		echo "Installing $pkg plugin"
		wp plugin install $pkg --activate
	done

	# Install latest version of roots and soil, activate it
	echo "Installing Sage Theme"
	git clone https://github.com/roots/sage.git src/themes/sage

	echo "Installing Soil Plugin"
	git clone https://github.com/roots/soil.git src/plugins/soil

fi
# Symlink working directories
# First clear out any links already present
find htdocs/wp-content/ -maxdepth 2 -type l -exec rm -f {} \;
# Next attach symlinks for eacy of our types.

# Plugins
echo "Linking working directory pluins"
find src/plugins/ -maxdepth 1 -mindepth 1 -type d -exec ln -s $PWD/{} $PWD/htdocs/wp-content/plugins/ \;

# Themes
echo "Linking working directory themes"
find src/themes/ -maxdepth 1 -mindepth 1 -type d -exec ln -s $PWD/{} $PWD/htdocs/wp-content/themes/ \;

# Finally activate soil
wp plugin activate soil

# The Vagrant site setup script will restart Nginx for us
echo "$site_name is now set up!";