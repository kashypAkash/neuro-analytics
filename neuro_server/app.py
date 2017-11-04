from flask import Flask
from flask_cors import CORS
from endpoints.user import login_api, UPLOAD_FOLDER
from models.user import initialize
from werkzeug.utils import secure_filename

ALLOWED_EXTENSIONS = set(['csv'])

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

app.register_blueprint(login_api)

CORS(app, resources={r"/*": {"origins": "*"}})
DEBUG = True
HOST = '0.0.0.0'
PORT = 5000

app.secret_key = '2#$$#SFGA#$@%FSG%#??|{KJHJK{KNKJK?KKJ\mnkjj'

if __name__ == '__main__':
    initialize()
    app.run(host=HOST, debug=DEBUG, port=PORT)
