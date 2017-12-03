package com.example.raghavendrkolisetty.neuro_android;

import android.text.format.DateFormat;

import java.util.Calendar;
import java.util.Date;

/**
 * Created by raghavendr.kolisetty on 11/14/17.
 */

public class DataCollector implements Runnable {

    AccelWriter accelWriter;
    String userEmail;
    int counter;
//    String prevTimeStamp = null;

    public DataCollector(AccelWriter accelWriter,String userEmail){
        this.accelWriter = accelWriter;
        this.userEmail = userEmail;
        this.counter = 0;
    }
    @Override
    public void run() {
        while(counter<40) {
            accelWriter.stop(Calendar.getInstance().getTime());
            accelWriter.closeStreamFile();
//            if(prevTimeStamp!=null){
//                accelWriter.addFileToList(prevTimeStamp);
//            }
            Date currTime = Calendar.getInstance().getTime();
//            prevTimeStamp = DateFormat.format("yyyyMMdd_kkmmss", currTime).toString();
            accelWriter.start(currTime, userEmail);
            accelWriter.init(accelWriter);
            counter++;
            try {
                Thread.sleep(30*1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
