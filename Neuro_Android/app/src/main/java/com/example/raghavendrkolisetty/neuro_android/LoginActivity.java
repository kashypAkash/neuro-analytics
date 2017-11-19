package com.example.raghavendrkolisetty.neuro_android;

import android.content.Intent;
import android.content.SharedPreferences;
import android.provider.Settings;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;


import org.json.JSONObject;

import java.io.File;
import java.io.IOException;

import okhttp3.FormBody;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import static android.preference.PreferenceManager.getDefaultSharedPreferences;

public class LoginActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        final EditText etUserName = (EditText) findViewById(R.id.etUserName);
        final EditText etPassword = (EditText) findViewById(R.id.etPassword);
        final Button bLogin = (Button) findViewById(R.id.bLogin);
        final TextView tvRegisterHere = (TextView) findViewById(R.id.tvRegisterHere);

        bLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SharedPreferences prefs = getDefaultSharedPreferences(getApplicationContext());
                SharedPreferences.Editor editor = prefs.edit();
                try {
                    editor.putString("userEmail", etUserName.getText().toString());
                    editor.commit();
                }catch (Exception e){
                    System.out.println("json exception in login response");
                }
                Thread t = new Thread(new Runnable() {
                    @Override
                    public void run() {
                        String email = etUserName.getText().toString();
                        String password = etPassword.getText().toString();
                        String json = "{'email':'" + email + "','password':'" + password + "'}";

                        final MediaType JSON
                                = MediaType.parse("application/json; charset=utf-8");
                        OkHttpClient client = new OkHttpClient();


                        RequestBody body = new FormBody.Builder()
                                .add("email_id",email).add("password",password).build();
                        Request request = new Request.Builder()
                                .url("https://flask-upload-app.herokuapp.com/api/v1/validate")
                                .post(body)
                                .build();
                        try (Response response = client.newCall(request).execute()) {
                            //System.out.print("printing response"+response.body().string());
                            String jsonData = response.body().string();
                            JSONObject Jobject = new JSONObject(jsonData);
                            if(Jobject.getInt("statusCode")==200){
                                Intent mainIntent = new Intent(LoginActivity.this,MainActivity.class);
                                LoginActivity.this.startActivity(mainIntent);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                    }
                });
                t.start();
            }
        });
    }
}
