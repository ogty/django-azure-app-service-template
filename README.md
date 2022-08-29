<h1 align="center">Django × Azure App Service Template</h1>

<p align="center">
    Created based on <a href="https://docs.microsoft.com/en-us/azure/app-service/quickstart-python?tabs=flask%2Cwindows%2Cazure-cli%2Cvscode-deploy%2Cdeploy-instructions-azportal%2Cterminal-bash%2Cdeploy-instructions-zip-azcli">Quick Start</a> and <a href="https://docs.microsoft.com/en-us/azure/app-service/tutorial-python-postgresql-app?tabs=flask%2Cwindows%2Cazure-portal%2Cterminal-bash%2Cazure-portal-access%2Cvscode-aztools-deploy%2Cdeploy-instructions-azportal%2Cdeploy-instructions--zip-azcli%2Cdeploy-instructions-curl-bash">Tutorial</a>
</p>

<div align="center">
    <img src="https://icon-library.com/images/django-icon/django-icon-0.jpg" width="30%" height="30%">
    <img src="./app-services.svg" width="30%" height="30%">
</div>

## Setup

```zsh
$ git clone https://github.com/ogty/django-azure-app-service-template.git
$ cd django-azure-app-service-template
$ make setup
$ make startproject project_name='<project-name>'
```

> **Note**  
> It is recommended to create an `activate` command in `alias`.
> ```zsh
> $ alias activate='source ./.venv/bin/activate'
> ```

## Deployment Steps

1. `make app-up`
2. `make config-set`
3. `make deploy`

Only run #3 when updating the application in the future.

> **Warning**  
> Do not interchange the order of `STATICFIELS_DIRS` and `STATIC_URL` in `settings.py`.  
> If you do, an error will occur with `DEBUG = False`.
> ```python
> STATICFILES_DIRS = (str(BASE_DIR.joinpath('static')),)
> STATIC_URL = 'static/'
> ```

## Using PostgreSQL

**`settings.py`**

```python
from dotenv import load_dotenv


load_dotenv()

...


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ['DBNAME'],
        'HOST': os.environ['DBHOST'],
        'USER': os.environ['DBUSER'],
        'PASSWORD': os.environ['DBPASS'] 
    }
}
```

> **Note**  
> `DATABASES` described by default should be commented out

```zsh
$ brew install postgresql
$ make local-db-setup
```

**`.env`**

```
DBHOST='localhost'
DBNAME='<database-name>'
DBUSER='<logged-in-user-name>'
DBPASS=''
```

```zsh
$ make db-deploy
```

> **Note**  
> It is assumed that all variables in the Makefile have already been entered.

PostgreSQL Flexible server > Checkbox > Save

```zsh
$ make ssh
# python manage.py migrate
```

## Make command list

- run
- install
- setup
- migrate
- startproject

<details>
  <summary>...</summary>

- startapp
- makemigrations
- createsuperuser
- app-up
- config-set
- deploy
- local-db-setup
- group-create
- plan-create
- app-create
- postgres-create
- rule-create
- postgres-show
- postgres-connect
- postgres-config-set
- ssh
- list
- db-deploy

</details>

```
wget https://www.python.org/downloads/ -q -O - | awk '/\<p\>Download the lates/{split($0,a,"/Python");split(a[1],a,"python/");print(a[2])}'
```
