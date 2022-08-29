admin_password        ?= 
admin_username        ?= 
app_name              ?= 
project_name          ?= 

END_IP_ADDRESS        := 0.0.0.0  # Warning: Use Azure Virtual Network for production deployments
START_IP_ADDRESS      := 0.0.0.0  # Warning: Use Azure Virtual Network for production deployments
GLOBAL_IP_ADDRESS     := $(shell curl -s ipecho.net/plain; echo)
VERSION               := $(shell curl -s https://www.python.org/downloads/ | awk ' \
                            /\<p\>Download the lates/ {                            \
                                split($$0, a, "/Python");                          \
                                split(a[1], a, "python/");                         \
                                print(a[2]);                                       \
                            }                                                      \
                        ')
POSTGRES_PLAN         := Standard_B1ms
PLAN                  := B1
LOCATION              := eastus
ZIP_FILE_NAME         := content
APP_SERVICE_PLAN_NAME := 
RESOURCE_GROUP_NAME   := 
APPLICATION_NAME      := 
DB_SERVER_NAME        := 
DBNAME                := 

run:
	@python manage.py runserver

install:
	@brew install azure-cli postgres

setup:
	@python3 -m venv .venv         \
	&& source ./.venv/bin/activate \
	&& pip install --upgrade pip   \
	&& pip install -r requirements.txt

migrate:
	@python manage.py migrate

# $ make startproject project_name=<name>
startproject:
	@django-admin startproject $(project_name) .                                       \
	&& sed -e 's/<project-name>/$(project_name)/g' ./manage.tpl > manage.bak           \
	&& mv manage.bak manage.py                                                         \
	&& sed -e 's/<project-name>/$(project_name)/g' ./production.tpl > ./production.bak \
	&& mv ./production.bak ./production.py                                             \
	&& mv ./production.py ./$(project_name)                                            \
	&& sed -e 's/<project-name>/$(project_name)/g' ./wsgi.tpl > ./wsgi.bak             \
	&& mv ./wsgi.bak ./wsgi.py                                                         \
	&& mv ./wsgi.py ./$(project_name)                                                  \
	&& sed -e "s/^        'DIRS': \[\],/\t\t'DIRS': \[BASE_DIR \/ 'templates'\],/g"    \
	./$(project_name)/settings.py > ./$(project_name)/settings.bak                     \
	&& mv ./$(project_name)/settings.bak ./$(project_name)/settings.py                 \
	&& sed -e "s/^STATIC_URL = 'static\/'/STATICFILES_DIRS = \(str\(BASE_DIR.joinpath\('static'\)\),\)\nSTATIC_URL = 'static\/'/g" \
	./$(project_name)/settings.py > ./$(project_name)/settings.bak                     \
	&& mv ./$(project_name)/settings.bak ./$(project_name)/settings.py

# $ make startapp app_name=<name>
startapp:
	@python manage.py startapp $(app_name)

makemigrations:
	@python manage.py makemigrations

createsuperuser:
	@python manage.py createsuperuser

app-up:
	@az webapp up                   \
	    --runtime PYTHON:$(VERSION) \
	    --sku $(PLAN)               \
	    --logs                      \
	    --name $(APPLICATION_NAME)  \
	    --resource-group $(RESOURCE_GROUP_NAME)

config-set:
	@az webapp config appsettings set           \
	    --resource-group $(RESOURCE_GROUP_NAME) \
	    --name $(APPLICATION_NAME)              \
	    --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true

deploy:
	@zip -r $(ZIP_FILE_NAME).zip . -x '.??*'    \
	&& az webapp deploy                         \
	    --name $(APPLICATION_NAME)              \
	    --resource-group $(RESOURCE_GROUP_NAME) \
	    --src-path $(ZIP_FILE_NAME).zip         \
	    --type zip

local-db-setup:
	@brew services start postgresql \
	&& psql postgres -c "CREATE DATABASE $(DBNAME);"

group-create:
	@az group create           \
	    --location $(LOCATION) \
	    --name $(RESOURCE_GROUP_NAME)

plan-create:
	@az appservice plan create                  \
	    --name $(APP_SERVICE_PLAN_NAME)         \
	    --resource-group $(RESOURCE_GROUP_NAME) \
	    --sku $(PLAN)                           \
	    --is-linux

app-create:
	@az webapp create                           \
	    --name $(APPLICATION_NAME)              \
	    --runtime 'PYTHON|$(VERSION)'           \
	    --plan $(APP_SERVICE_PLAN_NAME)         \
	    --resource-group $(RESOURCE_GROUP_NAME) \
	    --query 'defaultHostName'               \
	    --output table

# $ make postgres-create admin_username=<username> admin_password=<password>
postgres-create:
	@az postgres flexible-server create         \
	    --resource-group $(RESOURCE_GROUP_NAME) \
	    --name $(DB_SERVER_NAME)                \
	    --location $(LOCATION)                  \
	    --admin-user $(admin_username)          \
	    --admin-password $(admin_password)      \
	    --public-access None                    \
	    --sku-name $(POSTGRES_PLAN)             \
	    --tier Burstable

rule-create:
	@az postgres flexible-server firewall-rule create \
	    --resource-group $(RESOURCE_GROUP_NAME)       \
	    --name $(DB_SERVER_NAME)                      \
	    --rule-name AllowMyIP                         \
	    --start-ip-address $(GLOBAL_IP_ADDRESS)       \
	    --end-ip-address $(GLOBAL_IP_ADDRESS)

postgres-show:
	@az postgres flexible-server show \
	    --name $(DB_SERVER_NAME)      \
	    --resource-group $(RESOURCE_GROUP_NAME)

postgres-connect:
	@psql --host=$(DB_SERVER_NAME).postgres.database.azure.com \
	    --port=5432                                            \
	    --username=$(admin_username)                           \
	    --dbname=postgres                                      \
	    -c "CREATE DATABASE $(DBNAME);"

server-rule-create:
	@az postgres server firewall-rule create    \
	    --resource-group $(RESOURCE_GROUP_NAME) \
	    --server $(DB_SERVER_NAME)              \
	    --name AllowAllWindowsAzureIps          \
	    --start-ip-address $(START_IP_ADDRESS)  \
	    --end-ip-address $(END_IP_ADDRESS)

# $ make postgres-config-set admin_username=<username> admin_password=<password>
postgres-config-set:
	@az webapp config appsettings set           \
	    --resource-group $(RESOURCE_GROUP_NAME) \
	    --name $(APPLICATION_NAME)              \
	    --settings DBHOST=$(DB_SERVER_NAME) DBNAME=$(DBNAME) DBUSER=$(admin_username) DBPASS=$(admin_password)

ssh:
	@az webapp ssh --resource-group $(RESOURCE_GROUP_NAME) \
	    --name $(APPLICATION_NAME)

list:
	@awk '                          \
	    /^[-a-z]{1,}:$$/ {          \
	        split($$0, a, ":");     \
	        printf("- %s\n", a[1]); \
	    }                           \
	' Makefile

db-deploy:
	@make group-create       \
	&& make plan-create      \
	&& make app-create       \
	&& make postgres-create  \
	&& make rule-create      \
	&& make postgres-show    \
	&& make postgres-connect \
	&& make config-set       \
	&& make deploy
