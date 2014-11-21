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
	echo "Installing WordPress using WP-CLI"
	mkdir htdocs

	# Move into htdocs to run 'wp' commands.
	wp core download
	wp core config
	wp core install

	# delete starting posts
	wp post delete 1,2 --force

	#Install all WordPress.org plugins in the org_plugins file using CLI
	echo "Installing WordPress.org Plugins"
	if [[ -f config/org-plugins ]]
	then
		while IFS='' read -r line || [ -n "$line" ]
		do
			if [[ "#" != ${line:0:1} ]]
			then
				# Install Plugins & Activate them (why not?)
				wp plugin install $line --activate
			fi
		done < config/org-plugins
	fi
	# Move back to root to finish up shell commands.
	# cd ..

	# Install latest version of roots and soil, activate it
	git clone https://github.com/roots/roots.git htdocs/wp-content/themes/roots
	cd htdocs/wp-content/themes/roots
	npm install
	grunt dev
	cd ../../../..
	wp theme activate roots

	# Take care of some Roots activation stuff command line
	wp rewrite structure '/%postname%/'
	wp option update show_on_front page
	wp post create --porcelain | xargs wp option update page_on_front

	git clone https://github.com/roots/soil.git htdocs/wp-content/plugins/soil
	wp plugin activate soil
fi
# Symlink working directories
# First clear out any links already present
find htdocs/wp-content/ -maxdepth 2 -type l -exec rm -f {} \;
# Next attach symlinks for eacy of our types.
# Plugins
echo "Linking working directory pluins"
find src/plugins/ -maxdepth 1 -mindepth 1 -exec ln -s $PWD/{} $PWD/htdocs/wp-content/plugins/ \;
# Themes
echo "Linking working directory themes"
find src/themes/ -maxdepth 1 -mindepth 1 -exec ln -s $PWD/{} $PWD/htdocs/wp-content/themes/ \;

# The Vagrant site setup script will restart Nginx for us
echo "$site_name is now set up!";