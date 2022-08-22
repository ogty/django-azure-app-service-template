# Django × Azure App Service Template Repository

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

1. `make create`
2. `make setting`
3. `make deploy`

Only run #3 when updating the application in the future.
