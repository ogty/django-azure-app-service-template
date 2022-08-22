app_name ?= 
project_name ?= 
zip_file_path := 
# NOTE: globally unique application name
application_name := 
resource_group_name := 

run:
    @python manage.py runserver

install:
	@brew install azure-cli

setup:
	@python3 -m venv .venv \
	&& source ./.venv/bin/activate \
	&& pip install --upgrade pip \
	&& pip install -r requirements.txt

migrate:
    @python manage.py migrate

startproject:
    @django-admin startproject $(project_name) . \
    && sed \
    && mv ./manage.tpl ./manage.py \
    && sed \
    && mv ./production.tpl ./production.py \
    && mv ./production.py ./$(project_name) \
    && sed \
    && mv ./wsgi.tpl ./wsgi.py \
    && mv ./wsgi.py ./$(project_name) \
	&& "STATICFILES_DIRS = (str(BASE_DIR.joinpath('static')),)" >> ./$(project_name)/settings.py

startapp:
    @python manage.py startapp $(app_name)

makemigrations:
    @python manage.py makemigrations

createsuperuser:
    @python manage.py createsuperuser

setting:
    @az webapp config appsettings set \
        --resource-group $(resource_group_name) \
        --name $(application_name) \
        --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true

deploy:
    @zip -r $(zip_file_path).zip . -x '.??*' \
    && az webapp deploy \
        --name $(application_name) \
        --resource-group $(resource_group_name) \
        --src-path $(zip_file_path).zip \
        --type zip
