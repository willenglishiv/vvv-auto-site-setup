# Modify the variables below to match your project.

# This specifies the main site name in provisioning.
site_name='Example Site'

# This sets up the name of the DB and the user and password for the DB.
database='example_db'
dbuser='wp'
dbpass='wp'

# The site details for this site
domain='http://example.dev'
admin_user='zerocool'
admin_pass='password'
admin_email='anon@anon.net'

# salt key
salt_key='example'

wordpress_plugins=(
	# List out any plugins in the WordPress.org repository and they will be installed.
	# Each line should contain a plugin slug for wp-cli

	debug-bar
	debug-bar-console
	debug-bar-cron
	debug-bar-extender
	jetpack
	wordpress-importer
	developer
	# wordpress-seo
	# woocommerce
)