package com.example.raghavendrkolisetty.neuro_android;

import android.os.Environment;
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
import android.view.View;
import android.webkit.MimeTypeMap;
import android.widget.Button;

//import com.squareup.okhttp.MediaType;
//import com.squareup.okhttp.OkHttpClient;
//import com.squareup.okhttp.internal.http.Request;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.util.Calendar;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;


import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import static android.preference.PreferenceManager.getDefaultSharedPreferences;
import static java.lang.System.out;

public class MainActivity extends AppCompatActivity {

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

        String userEmail = null;
        try {
            userEmail = prefs.getString("userEmail",null);
        }catch (Exception e){
            System.out.println("exception while getting useremail from prefs");
        }
        AccelWriter accelWriter = new AccelWriter(context);
//        accelWriter.start(Calendar.getInstance().getTime(),userEmail);
//        accelWriter.init(accelWriter);
        DataCollector dataCollector = new DataCollector(accelWriter,userEmail);
        Thread thread = new Thread(dataCollector);
        thread.start();
        DataUploader dataUploader = new DataUploader(accelWriter,userEmail);
        Thread uploaderThread = new Thread(dataUploader);
        uploaderThread.start();
        final String rootPath = accelWriter.getStringPref(Globals.PREF_KEY_ROOT_PATH);
        final Button button = (Button)findViewById(R.id.button);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                Thread t = new Thread(new Runnable(){
                      @Override
                      public void run() {
                          File f = new File(rootPath+ "/hdl_accel__20171007_110927.csv");
                          String content_type = getMimeType(f.getPath());

                          String file_path = f.getAbsolutePath();
                          OkHttpClient client = new OkHttpClient();
                          RequestBody file_body = RequestBody.create(MediaType.parse(content_type),f);

                          RequestBody requestBody = new MultipartBody.Builder()
                                  .setType(MultipartBody.FORM)
                                  .addFormDataPart("type",content_type)
                                  .addFormDataPart("uploaded_file",file_path.substring(file_path.lastIndexOf("/")+1),file_body)
                                  .build();

                          Request request = new Request.Builder()
                                  .url("https://vast-cove-36444.herokuapp.com/file")
                                  .post(requestBody)
                                  .build();

                          try {
                              Response response = client.newCall(request).execute();

                              if(!response.isSuccessful()){
                                  throw new IOException("error: "+response);
                              }
                              else{
                                  Log.i("MainActivity",response.toString());
                              }
                          } catch (IOException e) {
                              e.printStackTrace();
                          }
                      }
                  });
                  t.start();

            }

        });


    }

    private String getMimeType(String path){
        String extension = MimeTypeMap.getFileExtensionFromUrl(path);
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
    }


}
