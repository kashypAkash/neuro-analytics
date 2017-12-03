package com.example.raghavendrkolisetty.neuro_android;

import android.accounts.Account;
import android.content.AbstractThreadedSyncAdapter;
import android.content.ContentProviderClient;
import android.content.ContentResolver;
import android.content.Context;
import android.content.SyncResult;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;

import com.opencsv.CSVReader;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

/**
 * Created by raghavendr.kolisetty on 11/27/17.
 */

public class SyncAdapter extends AbstractThreadedSyncAdapter {

    // Global variables
    // Define a variable to contain a content resolver instance
    ContentResolver mContentResolver;

    /**
     * Set up the sync adapter
     */
    public SyncAdapter(Context context, boolean autoInitialize) {
        super(context, autoInitialize);
        /*
         * If your app uses a content resolver, get an instance of it
         * from the incoming Context
         */
        mContentResolver = context.getContentResolver();
        Log.i("synctest", "ReaderSyncAdapter created");
    }

    /**
     * Set up the sync adapter. This form of the
     * constructor maintains compatibility with Android 3.0
     * and later platform versions
     */
    public SyncAdapter(
            Context context,
            boolean autoInitialize,
            boolean allowParallelSyncs) {
        super(context, autoInitialize, allowParallelSyncs);
        /*
         * If your app uses a content resolver, get an instance of it
         * from the incoming Context
         */
        mContentResolver = context.getContentResolver();

        Log.i("synctest", "ReaderSyncAdapter created");

    }

    @Override
    public void onPerformSync(Account account, Bundle extras, String authority, ContentProviderClient provider, SyncResult syncResult) {
        Log.i("neuro", "on performsync");

        String rootPath,userEmail;
        try {
            Log.i("neuro", (String)extras.get("email"));
            Log.i("neuro", "printing root path" +(String)extras.get("rootPath"));
            userEmail = (String) extras.get("email");
            rootPath = (String) extras.get("rootPath");
        }catch(Exception e){
            e.printStackTrace();
            return;
        }
        Log.i("neuro", rootPath);
        File parentDir = new File(rootPath);

        ArrayList<File> inFiles = new ArrayList<File>();
        File[] files = parentDir.listFiles();
        for (File file : files) {
            if(file.getName().endsWith(".csv")){
                    inFiles.add(file);
            }
        }
        int len = inFiles.size();
        if(len == 0 || len == 1){
            return;
        }
        for(int i=0;i<inFiles.size();i++){
            System.out.println("printing each file name "+inFiles.get(i));
        }
        System.out.println("number of files "+inFiles.size());
        for(int i=0;i<inFiles.size();i++){
            DataUploader dataUploader = new DataUploader();
            Log.i("neuro",inFiles.get(i).getAbsolutePath().toString());
//            CSVReader reader = null;
//            try {
//                reader = new CSVReader(new FileReader(files[i].getAbsolutePath().toString()));
//                String [] nextLine;
//                while ((nextLine = reader.readNext()) != null) {
//                    // nextLine[] is an array of values from the line
//                    System.out.println(nextLine[0] + nextLine[1] + "etc...");
//                }
//            } catch (FileNotFoundException e) {
//                e.printStackTrace();
//            } catch (IOException e){
//                e.printStackTrace();
//            }

            try {
                String line = null;
                FileReader fileReader = new FileReader(inFiles.get(i).getAbsolutePath().toString());
                BufferedReader bufferedReader =
                        new BufferedReader(fileReader);
                List<HashMap<String,String>> readings = new ArrayList<HashMap<String,String>>();
                bufferedReader.readLine(); //skipping header
//                while((line = bufferedReader.readLine()) != null) {
//
//                }
                while((line = bufferedReader.readLine()) != null) {
                    System.out.println("before formatting "+line);
                    line = line.replaceAll("[^\\p{Alpha}\\p{Digit}.@\\-,: ]+","");
                    //line = line.replaceAll("�","");
                    String vals[] = line.split(",");
                    if(vals.length!=28 || !vals[27].endsWith("com")){
                        continue;
                    }
                    //System.out.println("printing values --->");
                    for(int j=0;j<vals.length;j++){
                        //System.out.println(vals[j]);
                    }
                    HashMap<String,String> map = new HashMap<>();
                    map.put("diffSecs",vals[0]);
                    map.put("N_samples",vals[1]);
                    map.put("x_mean",vals[2]);
                    map.put("x_absolute_deviation",vals[3]);
                    map.put("x_standard_deviation",vals[4]);
                    map.put("x_max_deviation",vals[5]);
                    map.put("x_PSD_1",vals[6]);
                    map.put("x_PSD_3",vals[7]);
                    map.put("x_PSD_6",vals[8]);
                    map.put("x_PSD_10",vals[9]);
                    map.put("y_mean",vals[10]);
                    map.put("y_absolute_deviation",vals[11]);
                    map.put("y_standard_deviation",vals[12]);
                    map.put("y_max_deviation",vals[13]);
                    map.put("y_PSD_1",vals[14]);
                    map.put("y_PSD_3",vals[15]);
                    map.put("y_PSD_6",vals[16]);
                    map.put("y_PSD_10",vals[17]);
                    map.put("z_mean",vals[18]);
                    map.put("z_absolute_deviation",vals[19]);
                    map.put("z_standard_deviation",vals[20]);
                    map.put("z_max_deviation",vals[21]);
                    map.put("z_PSD_1",vals[22]);
                    map.put("z_PSD_3",vals[23]);
                    map.put("z_PSD_6",vals[24]);
                    map.put("z_PSD_10",vals[25]);
                    map.put("time",vals[26]);
                    map.put("email_id",vals[27]);
                    Date date = new Date();
//                    SimpleDateFormat formatter = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss.SS");
                    //yyyy-mm-dd HH:MM:SS
//                    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//                    String strDate= formatter.format(date);
//                    map.put("time",strDate);
//                    map.put("email_id",userEmail);
                    System.out.println("after formatting "+line);
                    readings.add(map);
                }

                // Always close files.
                bufferedReader.close();
                JsonData jsonData = new JsonData(userEmail,readings);
                dataUploader.jsonData = jsonData;
                dataUploader.filePath = inFiles.get(i).getAbsolutePath().toString();
                Thread thread = new Thread(dataUploader);
                thread.start();
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }
}