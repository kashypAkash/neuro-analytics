package com.example.raghavendrkolisetty.neuro_android;

import android.util.Log;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.IOException;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

/**
 * Created by raghavendr.kolisetty on 11/18/17.
 */

public class DataUploader implements Runnable{
    AccelWriter accelWriter;
    String rootPath;
    String fileName;
    String email;
    int counter;

    DataUploader(AccelWriter accelWriter,String email){
        this.accelWriter = accelWriter;
        this.counter = 0;
        this.rootPath = accelWriter.getStringPref(Globals.PREF_KEY_ROOT_PATH);
        this.email = email;
    }
    @Override
    public void run() {
        //File f = new File(rootPath+ "/hdl_accel__20171007_110927.csv");
        while (counter < 15) {
            fileName = accelWriter.getFileFromList();
            while (fileName == null) {
                try {
                    Thread.sleep(30 * 1000);
                    fileName = accelWriter.getFileFromList();
                    Log.i("DataUploader", fileName + "its file name");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            File f = new File(rootPath + "/" + "hdl_accel__" + fileName + ".csv");
            String extension = MimeTypeMap.getFileExtensionFromUrl(f.getPath());
            String content_type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
            Log.i("DataUploader",content_type); //text/comma-separated-values


            String file_path = f.getAbsolutePath();
            Log.i("DataUploader","file --> "+file_path.substring(file_path.lastIndexOf("/") + 1));
            OkHttpClient client = new OkHttpClient();
            RequestBody file_body = RequestBody.create(MediaType.parse(content_type), f);

            RequestBody requestBody = new MultipartBody.Builder()
                    .setType(MultipartBody.FORM)
                    .addFormDataPart("type", content_type)
                    .addFormDataPart("email_id",email)
                    .addFormDataPart("file", file_path.substring(file_path.lastIndexOf("/") + 1), file_body)
                    .build();

            Request request = new Request.Builder()
                    .url("https://flask-upload-app.herokuapp.com/api/v1/upload")
                    .post(requestBody)
                    .build();

            try {
                Response response = client.newCall(request).execute();

                if (!response.isSuccessful()) {
                    throw new IOException("error: " + response);
                } else {
                    accelWriter.removeFileFromList(fileName);
                    Log.i("MainActivity", response.toString());
                    Log.i("DataUploader", response.body().string());
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
