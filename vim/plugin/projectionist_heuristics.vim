let g:projectionist_heuristics = {
			\ "manage.py": {
			\   "*": {
			\     "console": "./manage.py shell",
			\     "dispatch": "./manage.py test",
			\     "start": "./manage.py runserver",
			\   },
			\   "*.html": {
			\     "type": "template",
			\   },
			\   "*/models.py": {
			\     "type": "models",
			\     "alternate": "{}/views.py",
			\     "related": ["{}/tests.py", "{}/urls.py", "{}/views.py"],
			\   },
			\   "*/urls.py": {
			\     "type": "urls",
			\     "related": ["{}/models.py", "{}/tests.py", "{}/views.py"],
			\     "template": [
			\       "from django.urls import path", "",
			\       "from . import views", "",
			\       "app_name = \"{basename}\"", "urlpatterns = [", "]"
			\     ]
			\   },
			\   "*/views.py": {
			\     "type": "views",
			\     "alternate": "{}/models.py",
			\     "related": ["{}/models.py", "{}/tests.py", "{}/urls.py"],
			\   },
			\   "*/tests.py": {
			\     "type": "tests",
			\     "related": ["{}/models.py", "{}/urls.py", "{}/views.py"],
			\   },
			\ }}

