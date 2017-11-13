package com.example.raghavendrkolisetty.neuro_android;

import android.content.Intent;
import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.android.volley.NetworkResponse;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONObject;

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

//        tvRegisterHere.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                Intent registerIntent = new Intent(LoginActivity.this,RegisterActivity.class);
//                LoginActivity.this.startActivity(registerIntent);
//            }
//        });

        bLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String username = etUserName.getText().toString();
                String password = etPassword.getText().toString();
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("email", username);
                    jsonObject.put("password",password);
                }catch (Exception e){
                    System.out.println("in the json exception phase");
                }
                SharedPreferences prefs = getDefaultSharedPreferences(getApplicationContext());
                SharedPreferences.Editor editor = prefs.edit();
                try {
                    editor.putString("email", username);
                    editor.commit();
                }catch (Exception e){
                    System.out.println("json exception in login response");
                }
                JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.POST, "http://52.32.123.205:5000/auth", jsonObject, new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        System.out.println("in JSON response"+response.toString());
                        SharedPreferences prefs = getDefaultSharedPreferences(getApplicationContext());
                        SharedPreferences.Editor editor = prefs.edit();
                        try {
                            editor.putString("access_token", response.getString("access_token"));
                            editor.commit();
                        }catch (Exception e){
                            System.out.println("json exception in login response");
                        }
                        //System.out.println("checking prefs"+prefs.getString("access_token",null));
                        Intent homeIntent = new Intent(LoginActivity.this,MainActivity.class);
                        LoginActivity.this.startActivity(homeIntent);
                    }

                }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        NetworkResponse networkResponse = error.networkResponse;
                        if(networkResponse!=null){
                            if(networkResponse.statusCode==400){
                                System.out.println("user already exists");
                            }
                        }
                        System.out.println("in error listener response"+error);
                    }
                });
                RequestQueue queue = Volley.newRequestQueue(LoginActivity.this);
                queue.add(jsonObjectRequest);
            }
        });

    }
}
