package com.app.checklink;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class XuLi extends AppCompatActivity  {
    TextView tai_khoan;
    TextView txt_network;
    TextView txt_chon, txt_check_link, txt_stop;
    ImageView reset;
    TextView txt_stuss;
    String tk;
    String network="";
    int time_check = 0;
    int key = 0;
    Spinner spinner;
    LinearLayout lin_network;
    List<String> listLink;
    private static final int REQUEST_CODE_POST_NOTIFICATIONS = 1001;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN
                , WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_xu_li);
        // Check and request notification permission
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.POST_NOTIFICATIONS)
                    != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(XuLi.this,  // Use XuLi.this instead of getApplicationContext()
                        new String[]{android.Manifest.permission.POST_NOTIFICATIONS},
                        REQUEST_CODE_POST_NOTIFICATIONS);
            }
        }
        mimap();
        // du lieu
        SharedPreferences sharedPreferences=getSharedPreferences("check-link",MODE_PRIVATE);
        tk=sharedPreferences.getString("tk","admin123");
        tai_khoan.setText("Tk : "+tk);
        txt_network.setText("Network : ......");


        spinner = (Spinner) findViewById(R.id.spinner);
        // Spinner Drop down elements
        List<String> categories = new ArrayList<String>();
        categories.add("Viettel");
        categories.add("VNPT");
        categories.add("FPT");
        categories.add("Mobifone");
        categories.add("Vietnamobile");


        // Creating adapter for spinner
        ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, categories);

        // Drop down layout style - list view with radio button
        dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        // attaching data adapter to spinner
        spinner.setAdapter(dataAdapter);
        // Set a listener to respond when an item is selected
        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                network= parent.getItemAtPosition(position).toString();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                // Do something when no item is selected
            }
        });

        //call du lieu
        txt_chon.setOnClickListener(new View.OnClickListener (){
            @Override
            public void onClick(View v) {
                Toast.makeText(XuLi.this,"Bạn đã chọn nhà mạng "+network +" !",Toast.LENGTH_SHORT).show();
                txt_network.setText("Network : "+network);
                lin_network.setVisibility(View.GONE);
                txt_chon.setVisibility(View.GONE);
                txt_check_link.setVisibility(View.VISIBLE);

            }
        });
        // reset
        reset.setOnClickListener(new View.OnClickListener (){
            @Override
            public void onClick(View v) {
                Toast.makeText(XuLi.this,"Reset thành công!",Toast.LENGTH_SHORT).show();
                startActivity(new Intent(XuLi.this, XuLi.class));
            }
        });
        // add link
        listLink=new ArrayList<>();
        listLink.add("https://google.com");
        listLink.add("https://app.fukaka.xyz");
        listLink.add("https://yufaga.com/1231");
        listLink.add("https://159.223.84.80:41674/4fa2fdbd");
        listLink.add("http://phimmoi.net/");
        listLink.add("https://top.112799.com/");
        listLink.add(
                "https://hot.336722.com/"
        );
        listLink.add("https://hot.336722.com/");
        listLink.add("https://88.tk657.com/sd");
        listLink.add("https://nice.336722.com/");
        // txt check link
        txt_check_link.setOnClickListener(new View.OnClickListener (){
            @Override
            public void onClick(View v) {
                txt_check_link.setVisibility(View.GONE);
                txt_stop.setVisibility(View.VISIBLE);
                Intent serviceIntent = new Intent(XuLi.this, UrlCheckService.class);
                serviceIntent.putStringArrayListExtra("url_list", (ArrayList<String>) listLink);
                startService(serviceIntent);
                txt_stuss.setVisibility(View.VISIBLE);

            }
        });
        // txt stop
        txt_stop.setOnClickListener(new View.OnClickListener (){
            @Override
            public void onClick(View v) {
                Intent serviceIntent = new Intent(XuLi.this, UrlCheckService.class);
                stopService(serviceIntent);
                txt_stop.setVisibility(View.GONE);
                lin_network.setVisibility(View.VISIBLE);
                txt_chon.setVisibility(View.VISIBLE);
                txt_stuss.setVisibility(View.GONE);

            }
        });

    }


    void mimap() {
        tai_khoan = findViewById(R.id.tk);
        txt_network = findViewById(R.id.txt_network);
        txt_chon = findViewById(R.id.chose);
        txt_check_link = findViewById(R.id.check);
        txt_stop = findViewById(R.id.stop);
        reset = findViewById(R.id.reset);
        txt_stuss = findViewById(R.id.stus_tb);
        lin_network=findViewById(R.id.network_chose);
    }
    // xử lí lấy link
    class  GetUrl extends AsyncTask<String,String,String>{
        String tk;
        String network;
        public GetUrl(String tk,String network){
            this.tk=tk;
            this.network=network;
        }
        @Override
        protected String doInBackground(String... strings) {
            SharedPreferences sharedPreferences=getSharedPreferences("check-link",MODE_PRIVATE);
            String id_tk=sharedPreferences.getString("tk","");
            JSONObject jsonObject=new JSONObject();
            try {
                jsonObject.put("tk",id_tk);
                jsonObject.put("network",network);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            String res=new httpRequest().performPostCall("",jsonObject);
            JSONObject dataa = null;
            try {
                dataa=new JSONObject(res);
                listLink=new ArrayList<>();
                JSONArray jsonArray=dataa.getJSONArray("url");
                for (int i=0; i<jsonArray.length();i++){
                    String url= (String) jsonArray.get(i);
                    listLink.add(url);
                }
            } catch(JSONException e) {
                e.printStackTrace();
            }

            return "true";
        }

        @Override
        protected void onPostExecute(String s) {
            super.onPostExecute(s);
            if (listLink!=null){
//                Intent serviceIntent = new Intent(XuLi.this, UrlCheckService.class);
//                serviceIntent.putStringArrayListExtra("url_list", (ArrayList<String>) listLink);
//                startService(serviceIntent);
//                txt_stuss.setVisibility(View.VISIBLE);
                new CheckUrlsTask().execute(listLink);

            }else {
                txt_stuss.setVisibility(View.VISIBLE);
                txt_stuss.setText("Hết Link !");
            }
        }
    }

    //  xử lí check status link
    class CheckUrlsTask extends AsyncTask<List<String>, Void, Map<String, Integer>> {

        @Override
        protected Map<String, Integer> doInBackground(List<String>... params) {
            List<String> urls = params[0];
            Map<String, Integer> urlStatusMap = new HashMap<>();

            for (String url : urls) {
                int code = -1;

                try {
                    URL urlObj = new URL(url);
                    HttpURLConnection connection = (HttpURLConnection) urlObj.openConnection();
                    connection.setRequestMethod("GET");
                    connection.connect();
                    code = connection.getResponseCode();
                } catch (Exception e) {
                    // Log the error or handle it as needed
                }

                urlStatusMap.put(url, code);
            }

            return urlStatusMap;
        }

        @Override
        protected void onPostExecute(Map<String, Integer> result) {
            // This method runs on the UI thread, so it's safe to update UI elements here
            StringBuilder resultMessage = new StringBuilder();

            for (Map.Entry<String, Integer> entry : result.entrySet()) {
                resultMessage.append("URL: ").append(entry.getKey())
                        .append(" - Status Code: ").append(entry.getValue()).append("\n");
            }

            Toast.makeText(getApplicationContext(), resultMessage.toString(), Toast.LENGTH_LONG).show();
            txt_stuss.setVisibility(View.VISIBLE);
           txt_stuss.setText(""+resultMessage.toString());
        }
    }



}
