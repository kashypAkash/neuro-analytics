from flask import Blueprint, jsonify
from flask_restful import reqparse, Resource, Api, marshal_with, marshal, fields
from werkzeug.utils import secure_filename
from werkzeug.datastructures import FileStorage
from models.user import *
from peewee import *
import datetime as dt

UPLOAD_FOLDER = './uploads'

user_fields = {
    'UserName': fields.String,
    'Password': fields.String,
    'EmailId': fields.String
}


class Login(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('username', required=True, help='username is required', location=['form', 'json'])
        self.reqparse.add_argument('password', required=True, help='password is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        print(args)
        try:
            if User.get(User.username == args['username']).password == args['password'] and User.get(
                            User.username == args['username']).Active == 'Active':
                return jsonify({'statusCode': 200, 'username': args['username']})
            elif User.get(User.username == args['username']).password == args['password'] and User.get(
                            User.username == args['username']).Active == 'Deactivated':
                print('Entered')
                return jsonify({'statusCode': 202})
            else:
                return jsonify({'statusCode': 400})
        except DoesNotExist:
            return jsonify({'statusCode': 400})


class AdminLogin(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('username', required=True, help='username is required', location=['form', 'json'])
        self.reqparse.add_argument('password', required=True, help='password is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        print(args)
        try:
            if Admin.get(Admin.username == args['username']).password == args['password']:
                return jsonify({'statusCode': 200, 'username': args['username']})
            else:
                return jsonify({'statusCode': 400})
        except DoesNotExist:
            return jsonify({'statusCode': 400})


class Register(Resource):
    '''This resource is used for  registering a user'''

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('username', required=True, help='username is required', location=['form', 'json'])
        self.reqparse.add_argument('password', required=True, help='password is required', location=['form', 'json'])
        self.reqparse.add_argument('emailid', required=True, help='email is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        User.create(**args)
        return jsonify({'statusCode': 200, 'result': 'success'})


class Upload(Resource):
    ''' This api end point is used for uploading the accelerometer reading file'''

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('file', type= FileStorage, required = True, help = 'file is required', location='files')
        self.reqparse.add_argument('username', required = True, help = 'file is required', location = ['form','json'])

    def post(self):
        args = self.reqparse.parse_args()
        file = args['file']
        filename = secure_filename(file.filename)
        file.save(os.path.join(UPLOAD_FOLDER, filename))
        # return redirect(url_for('uploaded_file', filename=filename))
        return jsonify({'statusCode': 200, 'result': 'success'})




login_api = Blueprint('resources.validate', __name__)

api = Api(login_api)
api.add_resource(Login, '/api/v1/validate', endpoint='login')
api.add_resource(Register, '/api/v1/register', endpoint='register')
api.add_resource(AdminLogin, '/api/v1/adminValidate', endpoint='adminlogin')
api.add_resource(Upload, '/api/v1/upload', endpoint='fileupload')
