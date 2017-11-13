package com.example.raghavendrkolisetty.neuro_android;

import java.io.File;
import java.io.IOException;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

/**
 * Created by raghavendr.kolisetty on 11/4/17.
 */

public class Request2 extends Thread{

    String fileString = null;
    Request2(String fileString){
        this.fileString = fileString;
    }
    public static final MediaType MEDIA_TYPE_MARKDOWN
            = MediaType.parse("text/x-markdown; charset=utf-8");

    private final OkHttpClient client = new OkHttpClient();

    public void run() {
        File file = new File(fileString);

        Request request = new Request.Builder()
                .url("http://vast-cove-36444.herokuapp.com/file")
                .post(RequestBody.create(MEDIA_TYPE_MARKDOWN, file))
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);

            System.out.println(response.body().string());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
