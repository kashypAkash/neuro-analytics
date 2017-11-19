package com.example.raghavendrkolisetty.neuro_android;

import java.util.Calendar;
import java.util.TimerTask;

/**
 * Created by raghavendr.kolisetty on 11/14/17.
 */

public class ScheduledTask extends TimerTask {

    AccelWriter accelWriter;
    String userEmail;

    public ScheduledTask(AccelWriter accelWriter,String userEmail){
        this.accelWriter = accelWriter;
        this.userEmail = userEmail;
    }

    @Override
    public void run() {
        accelWriter.stop(Calendar.getInstance().getTime());
        accelWriter.start(Calendar.getInstance().getTime(),userEmail);
        accelWriter.init(accelWriter);
    }
}
