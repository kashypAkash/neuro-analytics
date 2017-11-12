import pymysql, os

from peewee import *

# DATABASE = MySQLDatabase(os.environ['dbdatabase'], user=os.environ['dbuser'], passwd=os.environ['dbpassword'], host=os.environ['dbhost'], port=3306)
DATABASE = MySQLDatabase('neuro-db', user='root', passwd='root', host='127.0.0.1', port=3306)

class Admin(Model):
    username = CharField(unique=True)
    emailid = CharField(unique=True)
    password = CharField(max_length=40)

    class Meta:
        database = DATABASE


class User(Model):
    """A base model that will use our MySQL database"""
    username = CharField(unique=True)
    password = CharField(max_length=40)
    emailid = CharField(unique=True)
    active = CharField(max_length=20, default='Active')

    class Meta:
        database = DATABASE


class Acceleration(Model):

    '''A base model used to store accelerometer readings in mysql'''
    diffSecs = CharField(max_length=40, default=None)
    N_samples = CharField(max_length=40, default=None)
    x_mean = DoubleField(default=None)
    x_absoulute_deviation = DoubleField(default=None)
    x_standard_deviation = DoubleField(default=None)
    x_max_deviation = DoubleField(default=None)
    x_PSD_1 = DoubleField(default=None)
    x_PSD_3 = DoubleField(default=None)
    x_PSD_6 = DoubleField(default=None)
    x_PSD_10 = DoubleField(default=None)
    y_mean = DoubleField(default=None)
    y_absoulute_deviation = DoubleField(default=None)
    y_standard_deviation = DoubleField(default=None)
    y_max_deviation = DoubleField(default=None)
    y_PSD_1 = DoubleField(default=None)
    y_PSD_3 = DoubleField(default=None)
    y_PSD_6 = DoubleField(default=None)
    y_PSD_10 = DoubleField(default=None)
    z_mean = DoubleField(default=None)
    z_absoulute_deviation = DoubleField(default=None)
    z_standard_deviation = DoubleField(default=None)
    z_max_deviation = DoubleField(default=None)
    z_PSD_1 = DoubleField(default=None)
    z_PSD_3 = DoubleField(default=None)
    z_PSD_6 = DoubleField(default=None)
    z_PSD_10 = DoubleField(default=None)
    time = CharField(max_length= 60, default=None)
    user_name = CharField(max_length= 60, default=None)

    class Meta:
        database = DATABASE

class AccelerationUtil(Model):

    '''A class for value mapping readings in mysql'''
    def __init__(self, **kwargs):
        self.diffSecs = kwargs['diffSecs']
        self.N_samples = kwargs['N_samples']
        self.x_mean = kwargs['x_mean']
        self.x_absoulute_deviation = kwargs['x_absoulute_deviation']
        self.x_standard_deviation = kwargs['x_standard_deviation']
        self.x_max_deviation = kwargs['x_max_deviation']
        self.x_PSD_1 = kwargs['x_PSD_1']
        self.x_PSD_3 = kwargs['x_PSD_3']
        self.x_PSD_6 = kwargs['x_PSD_6']
        self.x_PSD_10 = kwargs['x_PSD_10']
        self.y_mean = kwargs['y_mean']
        self.y_absoulute_deviation = kwargs['y_absoulute_deviation']
        self.y_standard_deviation = kwargs['y_standard_deviation']
        self.y_max_deviation = kwargs['y_max_deviation']
        self.y_PSD_1 = kwargs['y_PSD_1']
        self.y_PSD_3 = kwargs['y_PSD_3']
        self.y_PSD_6 = kwargs['y_PSD_6']
        self.y_PSD_10 = kwargs['y_PSD_10']
        self.z_mean = kwargs['z_mean']
        self.z_absoulute_deviation = kwargs['z_absoulute_deviation']
        self.z_standard_deviation = kwargs['z_standard_deviation']
        self.z_max_deviation = kwargs['z_max_deviation']
        self.z_PSD_1 = kwargs['z_PSD_1']
        self.z_PSD_3 = kwargs['z_PSD_3']
        self.z_PSD_6 = kwargs['z_PSD_6']
        self.z_PSD_10 = kwargs['z_PSD_10']
        self.time = kwargs['time']
        self.user_name = kwargs['user_name']


def initialize():
    DATABASE.connect()
    DATABASE.create_tables([Admin, User, Acceleration], safe=True)
