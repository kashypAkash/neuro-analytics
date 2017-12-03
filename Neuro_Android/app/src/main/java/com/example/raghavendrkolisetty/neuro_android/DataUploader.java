package com.example.raghavendrkolisetty.neuro_android;

import android.util.Log;
import android.webkit.MimeTypeMap;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.PropertyAccessor;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;

/**
 * Created by raghavendr.kolisetty on 11/18/17.
 */
public class DataUploader implements Runnable{
    public static final MediaType JSON
            = MediaType.parse("application/json; charset=utf-8");
    JsonData jsonData;
    String jsonInString;
    String filePath;
    ObjectMapper mapper = new ObjectMapper();
    OkHttpClient client = new OkHttpClient();

    DataUploader(JsonData jsonData){
        this.jsonData = jsonData;
    }

    public DataUploader() {

    }

    @Override
    public void run() {
        try {
            jsonInString = mapper.writeValueAsString(jsonData);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        RequestBody body = RequestBody.create(JSON, jsonInString);
        Request request = new Request.Builder()
                .url("https://flask-upload-app.herokuapp.com/api/v1/upload")
                .post(body)
                .build();
        try (Response response = client.newCall(request).execute()) {
//            Log.i("DataUploader",response.body().string());
            String respData = response.body().string();
            Log.i("DataUploader",respData);
            JSONObject Jobject = new JSONObject(respData);
            if(Jobject.getInt("statusCode")==200){
                if(filePath!=null){
                    File file = new File(filePath);

                    if(file.delete())
                    {
                        System.out.println("File deleted successfully");
                    }
                    else
                    {
                        System.out.println("Failed to delete the file");
                    }
                }
            }
            else{
                if(filePath!=null) {
                    File file = new File(filePath);

                    if (file.delete()) {
                        System.out.println("File deleted successfully");
                    } else {
                        System.out.println("Failed to delete the file");
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}