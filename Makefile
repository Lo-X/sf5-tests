SHELL    = sh
EXEC_PHP = php
CONSOLE  = $(EXEC_PHP) bin/console
SYMFONY  = symfony
COMPOSER = composer
DOCSIFY  = docsify
YARN     = yarn
GIT      = git

##
## —— Project ——

setup: .env.local install assets ## Install and starts the project

run: ## Run embeded web server
	$(SYMFONY) server:start


deploy: ## Deploy the project. Usage: make deploy <target_name>
	@echo "TODO dep deploy $(filter-out $@,$(MAKECMDGOALS))"
%:  # Do nothing with extra arguments :
	@:

.PHONY: setup run deploy

##
## —— PHP / Composer ——

install: composer.lock ## Install vendors

update: ## Update vendors
	$(COMPOSER) update

.PHONY: install update

##
## —— Utils ——

assets: assets-build assets-install ## Run webpack to compile assets and then install them with symlinks in the public folder

assets-build: node_modules ## Run webpack to compile assets
	$(YARN) run dev

assets-install: purge ## Install the assets with symlinks in the public folder
	$(CONSOLE) assets:install public/ --symlink --relative

build-assets: assets-build

cc: ## Clear the cache
	$(CONSOLE) cache:clear

db-diff: ## Prints project changes that have not been passed on database yet
	$(CONSOLE) doctrine:schema:update --dump-sql

migrate: ## Migrate, executes Migrations files
	$(CONSOLE) doctrine:migration:migrate --no-interaction

migration: ## Creates a new Migration file
	$(CONSOLE) doctrine:migration:diff

purge: ## Purge cache and logs dir
	rm -rf var/cache/* var/logs/*

warmup: cc ## Clear the cache
	$(CONSOLE) cache:clear

watch: node_modules ## Run webpack to watch assets and compile on modification
	$(YARN) run watch

.PHONY: assets assets-build assets-install build-assets cc db-diff migrate migration purge warmup watch


##
## —— Tests ——

test: security-test unit-test functional-test ## Run unit and functional tests

unit-test: composer.lock ## Run unit tests
	$(EXEC_PHP) bin/phpunit --exclude-group functional

functional-test: composer.lock ## Run functional tests
	$(EXEC_PHP) bin/phpunit --group functional

security-test: composer.lock ## Run a security check on the application
	$(SYMFONY) check:security

.PHONY: test unit-test functional-test security-test


##
## —— Code Quality ——

lint: vendor/bin/php-cs-fixer ## Run php-cs-fixer and prints a diff (http://cs.sensiolabs.org)
	$(SHELL) vendor/bin/php-cs-fixer fix --dry-run --using-cache=no --diff --diff-format=udiff

lint-fix: vendor/bin/php-cs-fixer ## Apply php-cs-fixer fixes
	$(SHELL) vendor/bin/php-cs-fixer fix --using-cache=no --verbose

.PHONY: lint lint-fix


##
## —— Code Quality ——

doc-run: ## Runs the server documentation and watcher
	$(DOCSIFY) serve ./docs



# rules based on files
composer.lock:
	$(COMPOSER) install

node_modules:
	$(YARN) install

vendor/bin/php-cs-fixer:
	$(COMPOSER) require --dev friendsofphp/php-cs-fixer

.env.local: .env
	@if [ -f .env.local ]; \
	then\
		echo '\033[1;41m/!\ The .env file has changed. Please check your .env.local file (this message will not be displayed again).\033[0m';\
		touch .env.local;\
		exit 1;\
	else\
		echo cp .env .env.local;\
		cp .env .env.local;\
	fi

.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help
