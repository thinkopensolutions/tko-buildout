# ThinkOpen Solutions Buildout for Odoo
Odoo Buildout configuration files

This recipes for Buildout are a fully featured tools allowing you to define and deploy quickly Odoo installations of any kinds, ranging from development setups to fully automated production deployments or continuous integration.

Some of its main features include:
 * installation of Odoo server, uniformly across versions.
 * retrieval of main software and addons from various sources, including the major version control systems
 * ability to pinpoint everything for replayability
 * management of Odoo configuration
 * dedicated scripts creation for easy integration of external tools, such as test launchers
 * packaging: creation of self-contained equivalents for easy deployment in tightly controlled hosting environmenents.

# POSTGRESQL Installation
 * If you intent to run Odoo in your localhost, you'll need to install Postgresql database server. It is important to use same version as the RDS production one. To install 9.5 on Ubuntu 14.04 run:
```
$~> sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
$~> wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
$~> sudo apt-get update
$~> sudo apt-get install postgresql-9.5 postgresql-client-9.5
$~> sudo su - postgres
$postgres> psql -c "CREATE USER odoo80 WITH PASSWORD 'odoo80' CREATEDB;"
$postgres> psql template1 -c "CREATE EXTENSION unaccent;"

```
# BUILDOUT Installation
Follow this steps to build an Odoo installation from scratch:
 * Clone this repository into a new directory, for example:
```
$~> mkdir odoo80
$~> cd odoo80
$odoo80> git clone git@github.com:thinkopensolutions/tko-buildout.git
```
 * Run bash script from the repository (to install all dependencies):
```
$odoo80> ./tko-buildout/setup.sh
```
 * Answer the following script questions (example for localhost):
  * Select base buildout file to extend from list (odoo-80.cfg);
  * Select a part to extend (odoo80);
  * Insert database host (localhost);
  * Insert database port (5432);
  * Insert database user (odoo80);
  * Insert database password (odoo80);
  * Insert Odoo admin password (admin)
 * The script will create buildout.cfg file for you, run bootstrap, buildout and at the end launch selected Odoo.

# USAGE
 * Bootstrap with:
```
$odoo80> python bootstrap.py -c buildout.cfg # ATTENTION: Edit the buildout.cfg file before
```
 * Buildout with:
```
$odoo80> bin/buildout
```
 * This is the day-to-day operation, rerun to apply any changes you do to buildout.cfg, and update repositories, and start Odoo with (ex: for odoo-80.cfg):
```
$odoo80> bin/start_odoo80
```
 * You can place Odoo paramenters here like -d -u and others, example:
```
$odoo80> bin/start_odoo80 -d DATABASE -u MODULE --stop-after-init
```
