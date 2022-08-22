<h1 align="center">Django × Azure App Service Template</h1>

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

1. `make create`
2. `make setting`
3. `make deploy`

Only run #3 when updating the application in the future.
