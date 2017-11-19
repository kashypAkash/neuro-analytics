from flask import Blueprint, jsonify
from flask_restful import reqparse, Resource, Api, marshal_with, marshal, fields
from werkzeug.utils import secure_filename
from werkzeug.datastructures import FileStorage
from models.user import *
from peewee import *
from playhouse.shortcuts import model_to_dict
import json

import datetime as dt
import csv
import sys

UPLOAD_FOLDER = './uploads'

user_fields = {
    'UserName': fields.String,
    'Password': fields.String,
    'EmailId': fields.String
}


class Login(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('username', required=True, help='User name is required', location=['form', 'json'])
        self.reqparse.add_argument('password', required=True, help='password is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        print(args)
        try:
            if User.get(User.username == args['username']).password == args['password']: #and User.get(User.email_id == args['email_id']).Active == 'Active':
                return jsonify({'statusCode': 200, 'username': args['username']})
            else:
                return jsonify({'statusCode': 400})
        except DoesNotExist:
            return jsonify({'statusCode': 400})


class AdminLogin(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('email_id', required=True, help='email id is required', location=['form', 'json'])
        self.reqparse.add_argument('password', required=True, help='password is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        print(args)
        try:
            if Admin.get(Admin.username == args['email_id']).password == args['password']:
                return jsonify({'statusCode': 200, 'email id': args['email_id']})
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
        self.reqparse.add_argument('email_id', required=True, help='email is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        User.create(**args)
        return jsonify({'statusCode': 200, 'result': 'success'})

class UpdateProfile(Resource):
    '''This resource is used for  registering a user'''
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('name', required=True, help='name is required', location=['form', 'json'])
        self.reqparse.add_argument('gender', required=True, help='gender is required', location=['form', 'json'])
        self.reqparse.add_argument('date_of_birth', required=True, help='date of birth is required', location=['form', 'json'])
        self.reqparse.add_argument('telephone', required=True, help='telephone is required', location=['form', 'json'])
        self.reqparse.add_argument('password', required=True, help='password is required', location=['form', 'json'])
        self.reqparse.add_argument('email_id', required=True, help='email is required', location=['form', 'json'])
        self.reqparse.add_argument('location', required=True, help='location is required', location=['form', 'json'])
        self.reqparse.add_argument('username', required=True, help='username is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        q = User.update(name=args['name'], gender=args['gender'], date_of_birth=args['date_of_birth'],
                        telephone=args['telephone'], password=args['password'], email_id=args['email_id'],
            location=args['location']).where(User.username==args['username'])
        q.execute()
        return jsonify({'statusCode': 200, 'result': 'success'})


class GetUserDetails(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('username', required=True, help='username is required', location=['form', 'json'])

    def post(self):
        result=[]
        args = self.reqparse.parse_args()
        userDetails = User.get(User.username == args['username'])

        return jsonify({'statusCode': 200,'userInfo': json.dumps(model_to_dict(userDetails))});

class Upload(Resource):
    ''' This api end point is used for uploading the accelerometer reading file'''

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('file', type= FileStorage, required = True, help = 'file is required', location='files')
        self.reqparse.add_argument('email_id', required = True, help = 'file is required', location = ['form','json'])

    def parse_csv_file(self,filepath, result_id):
        reader = csv.DictReader(open(filepath, 'rb'))

        dict_list = []
        for line in reader:
            temp = AccelerationUtil(**line).__dict__
            temp['result_id'] = result_id
            dict_list.append(temp)

        return dict_list

    def post(self):
        args = self.reqparse.parse_args()
        file = args['file']
        email_id = args['email_id'].strip()
        filename = secure_filename(file.filename)
        file.save(os.path.join(UPLOAD_FOLDER, filename))

        try:
            cursor = DATABASE.execute_sql('select * from neuro_db.result where id = (select max(id) from neuro_db.result where email_id = %s)', email_id)
            my_dict = cursor.fetchone()

            if my_dict is None or len(my_dict) == 0:
                # insert the user
                result = Result(email_id = email_id)
                if result.save() == 1:
                    cursor = DATABASE.execute_sql('select * from neuro_db.result where id = (select max(id) from neuro_db.result where email_id = %s)', email_id)
                    my_dict = cursor.fetchone()

            result_id = my_dict[0]
            list_of_objs = self.parse_csv_file(os.path.join(UPLOAD_FOLDER, filename),result_id)

            with DATABASE.atomic():
                Acceleration.insert_many(list_of_objs).execute()

            return jsonify({'statusCode': 200, 'result': 'success'})

            return jsonify({'statusCode': 400, 'result': 'error'})
        except Exception as e:
            return jsonify({'statusCode': 500, 'result': e.message})


login_api = Blueprint('resources.validate', __name__)

api = Api(login_api)
api.add_resource(Login, '/api/v1/validate', endpoint='login')
api.add_resource(Register, '/api/v1/register', endpoint='register')
api.add_resource(UpdateProfile, '/api/v1/updateProfile', endpoint='updateprofile')
api.add_resource(GetUserDetails, '/api/v1/getUserDetails', endpoint='getuserdetails')
api.add_resource(AdminLogin, '/api/v1/adminValidate', endpoint='adminlogin')
api.add_resource(Upload, '/api/v1/upload', endpoint='fileupload')
