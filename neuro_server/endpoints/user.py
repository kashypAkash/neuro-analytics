from flask import Blueprint, jsonify, request
from flask_restful import reqparse, Resource, Api, fields
from playhouse.shortcuts import model_to_dict

from models.user import *

UPLOAD_FOLDER = os.getcwd() + '/uploads'

user_fields = {
    'UserName': fields.String,
    'Password': fields.String,
    'EmailId': fields.String
}


class Login(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('email_id', required=True, help='email id is required', location=['form', 'json'])
        self.reqparse.add_argument('password', required=True, help='password is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        print(args)
        try:
            if User.get(User.email_id == args['email_id']).password == args[
                'password']:  # and User.get(User.email_id == args['email_id']).Active == 'Active':
                return jsonify({'statusCode': 200, 'email_id': args['email_id']})
            else:
                return jsonify({'statusCode': 400})
        except DoesNotExist as e:
            return jsonify({'statusCode': 400, 'error': str(e)})
        except Exception as e:
            return jsonify({'statusCode': 500, 'error': str(e)})


class AdminLogin(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('email_id', required=True, help='email_id is required', location=['form', 'json'])
        self.reqparse.add_argument('password', required=True, help='password is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        print(args)
        try:
            if Admin.get(Admin.email_id == args['email_id']).password == args['password']:
                return jsonify({'statusCode': 200, 'email_id': args['email_id']})
            else:
                return jsonify({'statusCode': 400})
        except DoesNotExist as e:
            return jsonify({'statusCode': 400, 'error':str(e)})
        except Exception as e:
            return jsonify({'statusCode': 500, 'error': str(e)})


class Register(Resource):
    '''This resource is used for  registering a user'''

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('username', required=True, help='username is required', location=['form', 'json'])
        self.reqparse.add_argument('password', required=True, help='password is required', location=['form', 'json'])
        self.reqparse.add_argument('email_id', required=True, help='email is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        try:
            User.create(**args)
            return jsonify({'statusCode': 200, 'result': 'success'})
        except DatabaseError as e:
            return jsonify({'statusCode': 400, 'error': str(e)})
        except Exception as e:
            return jsonify({'statusCode': 500, 'error': str(e)})


class UpdateProfile(Resource):
    '''This resource is used for  registering a user'''

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('name', required=True, help='name is required', location=['form', 'json'])
        self.reqparse.add_argument('gender', required=True, help='gender is required', location=['form', 'json'])
        self.reqparse.add_argument('date_of_birth', required=True, help='date of birth is required',
                                   location=['form', 'json'])
        self.reqparse.add_argument('telephone', required=True, help='telephone is required', location=['form', 'json'])
        self.reqparse.add_argument('password', required=True, help='password is required', location=['form', 'json'])
        self.reqparse.add_argument('email_id', required=True, help='email is required', location=['form', 'json'])
        self.reqparse.add_argument('location', required=True, help='location is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        try:
            q = User.update(name=args['name'], gender=args['gender'], date_of_birth=args['date_of_birth'],
                            telephone=args['telephone'], password=args['password'],
                            location=args['location']).where(User.email_id == args['email_id'])
            q.execute()
            return jsonify({'statusCode': 200, 'result': 'success'})
        except DatabaseError as e:
            return jsonify({'statusCode': 400, 'error': str(e)})
        except Exception as e:
            return jsonify({'statusCode': 500, 'error': str(e)})



class GetUserDetails(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('email_id', required=True, help='email id is required', location=['form', 'json'])

    def post(self):
        result = []
        args = self.reqparse.parse_args()
        try:
            userDetails = User.get(User.email_id == args['email_id'])

            return jsonify({'statusCode': 200, 'userInfo': json.dumps(model_to_dict(userDetails))})
        except DatabaseError as e:
            return jsonify({'statusCode': 400, 'error': str(e)})
        except Exception as e:
            return jsonify({'statusCode': 500, 'error': str(e)})


class Upload(Resource):
    ''' This api end point is used for uploading the accelerometer reading file'''

    def __init__(self):
        self.reqparse = reqparse.RequestParser(bundle_errors=True)
        self.reqparse.add_argument('email_id', required=True, help='email_id is required', location=['form', 'json'])
        self.reqparse.add_argument('readings', required=True, help='readings is required', location='json')


    def parse_csv_file(self,list_of_readings, result_id):

        dict_list = []
        try:
            for reading in list_of_readings:
                temp = AccelerationUtil(**reading).__dict__
                temp['result_id'] = result_id
                dict_list.append(temp)
        except Exception as e:
            pass
        return dict_list

    def post(self):

        args = self.reqparse.parse_args()
        readings = request.get_json()['readings']
        email_id = args['email_id']
        # readings = args['readings']

        try:
            cursor = DATABASE.execute_sql(
                'select * from neuro_db.result where id = (select max(id) from neuro_db.result where email_id = %s and classification = "")',
                email_id)
            my_dict = cursor.fetchone()

            if my_dict is None or len(my_dict) == 0:
                # insert the user
                result = Result(email_id=email_id)
                if result.save() == 1:
                    cursor = DATABASE.execute_sql(
                        'select * from neuro_db.result where id = (select max(id) from neuro_db.result where email_id = %s and classification = "")',
                        email_id, '')
                    my_dict = cursor.fetchone()

            result_id = my_dict[0]

            list_of_objs = self.parse_csv_file(readings, result_id)

            with DATABASE.atomic():
                Acceleration.insert_many(list_of_objs).execute()

            return jsonify({'statusCode': 200, 'result': 'success'})
        except Exception as e:
            return jsonify({'statusCode': 500, 'result': str(e)})


class GetUserCurrentReport(Resource):

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('email_id', required=True, help='email id is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        try:
            user_current_result = Result.select().where(Result.email_id == args['email_id']).order_by(
                Result.date_taken.desc()).limit(1).get();
            print(user_current_result)
            return jsonify({'statusCode': 200, 'userInfo': json.dumps(model_to_dict(user_current_result), default=str)})
        except DatabaseError as e:
            return jsonify({'statusCode': 400, 'error': str(e)})
        except Exception as e:
            return jsonify({'statusCode': 500, 'error': str(e)})

class GetUserReports(Resource):

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('email_id', required=True, help='email id is required', location=['form', 'json'])

    def post(self):
        result = []
        args = self.reqparse.parse_args()

        try:
            q = Result.select().where(Result.email_id == args['email_id']);
            user_reports = q.execute();

            for report in user_reports:
                report_details = {}
                report_details['date_taken'] = report.date_taken
                report_details['accuracy'] = report.accuracy
                report_details['classification'] = report.classification
                report_details['model_name'] = report.model_name
                report_details['id'] = report.id
                report_details['no_of_readings'] = report.no_of_readings
                report_details['id'] = report.id

                result.append(report_details)
            print(result);
            return jsonify({'statusCode': 200, 'reports': result})
        except DatabaseError as e:
            return jsonify({'statusCode': 400, 'error': str(e)})
        except Exception as e:
            return jsonify({'statusCode': 500, 'error': str(e)})


class GetAllUsers(Resource):
    def __init__(self):
        self.reqparse = reqparse.RequestParser()

    def post(self):
        result = []
        args = self.reqparse.parse_args()
        try:
            users = User.select();

            for user in users:
                userInfo = {}
                userInfo['email_id'] = user.email_id;
                result.append(userInfo)

            return jsonify({'statusCode': 200, 'users': result})
        except DatabaseError as e:
            return jsonify({'statusCode': 400, 'error': str(e)})
        except Exception as e:
            return jsonify({'statusCode': 500, 'error': str(e)})

class GetResultIdOfUser(Resource):

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('email_id', required=True, help='email id is required', location=['form', 'json'])

    def post(self):
        args = self.reqparse.parse_args()
        email_id = args['email_id']

        try:
            with DATABASE.atomic():
                #cursor = DATABASE.execute_sql('select * from neuro_db.result where id = (select max(id) from neuro_db.result where email_id = %s and classification = "")', email_id)
                cursor = Result.raw('select * from neuro_db.result where id = (select max(id) from neuro_db.result where email_id = %s and classification = "")', email_id)
                my_dict = [item for item in cursor.dicts()]

            return jsonify({'statusCode': 200, 'details': my_dict});
        except Exception as e:
            return jsonify({'statusCode': 400, 'details': my_dict});

class Dashboard(Resource):

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('email_id', required = True, help = 'email id is required', location = ['form','json'])
        self.reqparse.add_argument('start_date', required = True, help = 'start date is required', location = ['form','json'])
        self.reqparse.add_argument('end_date', required = True, help = 'end date is required', location = ['form','json'])

    def post(self):
        args = self.reqparse.parse_args()
        email_id = args['email_id']
        start_date = args['start_date']
        end_date = args['end_date']

        try:
            with DATABASE.atomic():
                cursor = Acceleration.select(Acceleration.time, Acceleration.x_standard_deviation, Acceleration.y_standard_deviation, Acceleration.z_standard_deviation).where(Acceleration.email_id == email_id, Acceleration.time >= start_date, Acceleration.time < end_date).order_by(+Acceleration.time).dicts()
                return jsonify({'status':200, 'data': list(cursor)})
        except Exception as e:
            return jsonify({'status':400, 'error': str(e)})


login_api = Blueprint('resources.validate', __name__)

api = Api(login_api)
api.add_resource(Login, '/api/v1/validate', endpoint='login')
api.add_resource(Register, '/api/v1/register', endpoint='register')
api.add_resource(UpdateProfile, '/api/v1/updateProfile', endpoint='updateprofile')
api.add_resource(GetUserDetails, '/api/v1/getUserDetails', endpoint='getuserdetails')
api.add_resource(AdminLogin, '/api/v1/adminValidate', endpoint='adminlogin')
api.add_resource(Upload, '/api/v1/upload', endpoint='fileupload')
api.add_resource(GetUserCurrentReport, '/api/v1/getUserCurrentReport', endpoint='getusercurrentreport')
api.add_resource(GetUserReports, '/api/v1/getUserReports', endpoint='getuserreports')
api.add_resource(GetAllUsers, '/api/v1/getAllUsers', endpoint='getallusers')
api.add_resource(GetResultIdOfUser, '/api/v1/getResultId', endpoint = 'getresultidofuser')
api.add_resource(Dashboard, '/api/v1/timeseries', endpoint = 'gettimeseries')
