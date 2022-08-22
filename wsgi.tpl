import os

from django.core.wsgi import get_wsgi_application


settings_module = '<project-name>.production' if 'WEBSITE_HOSTNAME' in os.environ else '<project-name>.settings'
os.environ.setdefault('DJANGO_SETTINGS_MODULE', settings_module)

application = get_wsgi_application()
