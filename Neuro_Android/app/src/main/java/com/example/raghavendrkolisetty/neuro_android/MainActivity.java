package com.example.raghavendrkolisetty.neuro_android;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import android.Manifest;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.preference.PreferenceManager;
import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.io.File;
import java.util.Calendar;
import java.util.List;
import java.util.logging.Logger;

public class MainActivity extends AppCompatActivity implements SensorEventListener{

    SensorManager mSensorManager;
    Sensor mSensor;
    private static Context context;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        MainActivity.context = getApplicationContext();
        File file = context.getExternalFilesDir("accel");
        Log.i("MainActivity", file.toString());

        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {

            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                    1);
        }
        Log.i("MainActivity",context.getFilesDir().toString());
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString(Globals.PREF_KEY_ROOT_PATH,file.toString());
        editor.commit();

        AccelWriter accelWriter = new AccelWriter(context);
        accelWriter.start(Calendar.getInstance().getTime());
        accelWriter.init(accelWriter);
//        mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
//        if (mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) != null){
//            mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
//            mSensorManager.registerListener(this, mSensor , SensorManager.SENSOR_DELAY_FASTEST);
//            Log.i("MainActivity","sensor existsss");
//        }
//        else {
//            Log.i("MainActivity","sensor doesn't exist");
//        }
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        //Log.i("MainActivity","x"+event.values[0]);
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        //Log.i("MainActivity",event.values.toString());
    }
}
