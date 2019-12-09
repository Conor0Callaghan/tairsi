import sys

activate_this = '/var/www/app/tairsi/venv/bin/activate_this.py'
with open(activate_this) as file_:
    exec(file_.read(), dict(__file__=activate_this))

sys.path.insert(0, '/var/www/app')

from tairsi.tairsiapp import app as application
