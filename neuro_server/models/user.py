import pymysql, os

from peewee import *

DATABASE = MySQLDatabase(os.environ['dbdatabase'], user=os.environ['dbuser'], passwd=os.environ['dbpassword'], host=os.environ['dbhost'], port=3306)

class Admin(Model):
    username = CharField(unique=True)
    email_id = CharField(unique=True)
    password = CharField(max_length=40)

    class Meta:
        database = DATABASE


class User(Model):
    """A base model that will use our MySQL database"""
    username = CharField(unique=True)
    name = CharField(max_length=40, null=True)
    gender = CharField(max_length=40, null=True)
    password = CharField(max_length=40)
    email_id = CharField(unique=True)
    date_of_birth = CharField(max_length=40, null= True)
    telephone = CharField(max_length=40, null = True)
    location = CharField (max_length=40, null = True)

    class Meta:
        database = DATABASE


class Acceleration(Model):
    '''A base model used to store accelerometer readings in mysql'''
    diffSecs = CharField(max_length=128, default=None)
    N_samples = CharField(max_length=128, default=None)
    x_mean = DoubleField(default=None)
    x_absolute_deviation = DoubleField(default=None)
    x_standard_deviation = DoubleField(default=None)
    x_max_deviation = DoubleField(default=None)
    x_PSD_1 = DoubleField(default=None)
    x_PSD_3 = DoubleField(default=None)
    x_PSD_6 = DoubleField(default=None)
    x_PSD_10 = DoubleField(default=None)
    y_mean = DoubleField(default=None)
    y_absolute_deviation = DoubleField(default=None)
    y_standard_deviation = DoubleField(default=None)
    y_max_deviation = DoubleField(default=None)
    y_PSD_1 = DoubleField(default=None)
    y_PSD_3 = DoubleField(default=None)
    y_PSD_6 = DoubleField(default=None)
    y_PSD_10 = DoubleField(default=None)
    z_mean = DoubleField(default=None)
    z_absolute_deviation = DoubleField(default=None)
    z_standard_deviation = DoubleField(default=None)
    z_max_deviation = DoubleField(default=None)
    z_PSD_1 = DoubleField(default=None)
    z_PSD_3 = DoubleField(default=None)
    z_PSD_6 = DoubleField(default=None)
    z_PSD_10 = DoubleField(default=None)
    time = CharField(max_length=128, default=None)
    email_id = CharField(max_length=128, default=None)
    result_id = IntegerField(default=None)

    class Meta:
        database = DATABASE


class AccelerationUtil(Model):
    '''A class for value mapping readings in mysql'''

    def __init__(self, **kwargs):
        self.diffSecs = kwargs['diffSecs']
        self.N_samples = kwargs['N_samples']
        self.x_mean = kwargs['x_mean']
        self.x_absolute_deviation = kwargs['x_absolute_deviation']
        self.x_standard_deviation = kwargs['x_standard_deviation']
        self.x_max_deviation = kwargs['x_max_deviation']
        self.x_PSD_1 = kwargs['x_PSD_1']
        self.x_PSD_3 = kwargs['x_PSD_3']
        self.x_PSD_6 = kwargs['x_PSD_6']
        self.x_PSD_10 = kwargs['x_PSD_10']
        self.y_mean = kwargs['y_mean']
        self.y_absolute_deviation = kwargs['y_absolute_deviation']
        self.y_standard_deviation = kwargs['y_standard_deviation']
        self.y_max_deviation = kwargs['y_max_deviation']
        self.y_PSD_1 = kwargs['y_PSD_1']
        self.y_PSD_3 = kwargs['y_PSD_3']
        self.y_PSD_6 = kwargs['y_PSD_6']
        self.y_PSD_10 = kwargs['y_PSD_10']
        self.z_mean = kwargs['z_mean']
        self.z_absolute_deviation = kwargs['z_absolute_deviation']
        self.z_standard_deviation = kwargs['z_standard_deviation']
        self.z_max_deviation = kwargs['z_max_deviation']
        self.z_PSD_1 = kwargs['z_PSD_1']
        self.z_PSD_3 = kwargs['z_PSD_3']
        self.z_PSD_6 = kwargs['z_PSD_6']
        self.z_PSD_10 = kwargs['z_PSD_10']
        self.time = kwargs['time']
        self.email_id = kwargs['email_id']
        # self.result_id = kwargs['result_id']


class Result(Model):

    ''' Results Model'''
    email_id = CharField(max_length=128, default=None)
    classification = CharField(max_length=128, default=None)
    accuracy = DoubleField(null=True)
    date_taken = DateField(null=True)
    model_name = CharField(max_length=128, null=True)

    class Meta:
        database = DATABASE


def initialize():
    DATABASE.connect()
    DATABASE.create_tables([Admin, User, Acceleration, Result], safe=True)
