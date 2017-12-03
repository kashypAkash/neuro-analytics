package com.example.raghavendrkolisetty.neuro_android;

import java.util.HashMap;
import java.util.List;

/**
 * Created by raghavendr.kolisetty on 12/2/17.
 */

public class JsonData {

    public String email_id;
    public List<HashMap<String,String>> readings;
    JsonData(String email_id,List<HashMap<String,String>> list){
        this.email_id = email_id;
        this.readings = list;
    }
}
