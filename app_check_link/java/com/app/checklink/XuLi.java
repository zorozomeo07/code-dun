package com.app.checklink;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.util.Log;
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

import java.util.ArrayList;
import java.util.List;

public class XuLi extends AppCompatActivity {
    TextView tai_khoan;
    TextView txt_network;
    TextView txt_chon, txt_check_link, txt_stop;
    ImageView reset;
    TextView txt_stuss;
    String tk;
    String network = "";
    int time_check = 0;
    int key = 0;
    Spinner spinner;
    LinearLayout lin_network;
    List<String> listNetWork =new ArrayList<>();
    SharedPreferences sharedPreferences;
    SharedPreferences.Editor editor;
    private static final int REQUEST_CODE_POST_NOTIFICATIONS = 1001;
    String networktype="";

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
        sharedPreferences = getSharedPreferences("check-link", MODE_PRIVATE);
        // check net
        key=sharedPreferences.getInt("key",0);
        if(key>0){
            txt_check_link.setVisibility(View.GONE);
            txt_stop.setVisibility(View.VISIBLE);
            txt_stuss.setVisibility(View.VISIBLE);
            lin_network.setVisibility(View.GONE);
            txt_chon.setVisibility(View.GONE);
        }else {
            lin_network.setVisibility(View.VISIBLE);
        }

        // du lieu
        editor = sharedPreferences.edit();
        tk = sharedPreferences.getString("tk", "admin123");
        tai_khoan.setText("Tk : " + tk);
        txt_network.setText("Network : ......");
        networktype=NetworkUtil.getNetworkType(XuLi.this);


        spinner = (Spinner) findViewById(R.id.spinner);
        // Spinner Drop down elements
        List<String> categories = new ArrayList<String>();
        categories.add("Viettel");
        categories.add("VNPT");
        categories.add("FPT");
        categories.add("Mobifone");
        categories.add("Vietnamobile");
        new GetNetWork(tk).execute();
        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                network = parent.getItemAtPosition(position).toString();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                // Do something when no item is selected
            }
        });

        //call du lieu
        txt_chon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(XuLi.this, "Bạn đã chọn nhà mạng " + network + " !", Toast.LENGTH_SHORT).show();
                txt_network.setText("Network : " + network);
                lin_network.setVisibility(View.GONE);
                txt_chon.setVisibility(View.GONE);
                txt_check_link.setVisibility(View.VISIBLE);
                network=network +" - "+networktype;
                Log.d("abcdc",network);
//                Toast.makeText(XuLi.this,""+network,Toast.LENGTH_SHORT).show();


            }
        });
        // reset
        reset.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                AlertDialog.Builder dialog = new AlertDialog.Builder(XuLi.this);
                dialog.setMessage("Bạn chắc chắn muốn reset lại ?");

// Set the Negative Button (Cancel button)
                dialog.setNegativeButton("Không", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int which) {
                        // Action to perform when the user clicks "Không" (No/Cancel)
                        dialogInterface.dismiss(); // Close the dialog
                    }
                });

// Optionally, you can add a positive button if needed
                dialog.setPositiveButton("Có", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int which) {
                        // Action to perform when the user clicks "Có" (Yes/OK)
                        // Add your reset logic here
                        editor.putInt("key", 0);
                        editor.commit();
                        // reset dung check
                        Intent serviceIntent = new Intent(XuLi.this, UrlCheckService.class);
                        stopService(serviceIntent);
                        // reset lai trang
                        Toast.makeText(XuLi.this, "Reset thành công!", Toast.LENGTH_SHORT).show();
                        startActivity(new Intent(XuLi.this, XuLi.class));
                    }
                });

            // Show the dialog
                dialog.show();

            }
        });

        // txt check link
        txt_check_link.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                txt_check_link.setVisibility(View.GONE);
                txt_stop.setVisibility(View.VISIBLE);
                Intent serviceIntent = new Intent(XuLi.this, UrlCheckService.class);
                serviceIntent.putExtra("network",network);
                startService(serviceIntent);
                txt_stuss.setVisibility(View.VISIBLE);
                // push key
                editor.putInt("key", 1);
                editor.commit();
//               networktype=NetworkUtil.getNetworkType(XuLi.this);
//                Log.d("abcdc",networktype);

            }
        });
        // txt stop
        txt_stop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent serviceIntent = new Intent(XuLi.this, UrlCheckService.class);
                stopService(serviceIntent);
                txt_stop.setVisibility(View.GONE);
                lin_network.setVisibility(View.VISIBLE);
                txt_chon.setVisibility(View.VISIBLE);
                txt_stuss.setVisibility(View.GONE);
                editor.putInt("key", 0);
                editor.commit();

               // Toast.makeText(XuLi.this,"Dừng check link thành công !",Toast.LENGTH_SHORT).show();

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
        lin_network = findViewById(R.id.network_chose);
    }

    // xử lí lấy link
    class GetNetWork extends AsyncTask<String, Void, List<String>> {
        String tk;
        List<String> listNetWork;

        public GetNetWork(String tk) {
            this.tk = tk;
            this.listNetWork = new ArrayList<>();
        }

        @Override
        protected List<String> doInBackground(String... strings) {
            SharedPreferences sharedPreferences = getSharedPreferences("check-link", MODE_PRIVATE);
            String id_tk = sharedPreferences.getString("tk", "");
            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("tk", id_tk);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            String res = new httpRequest().performPostCall("", jsonObject);
            try {
                JSONObject dataa = new JSONObject(res);
                JSONArray jsonArray = dataa.getJSONArray("url");
                for (int i = 0; i < jsonArray.length(); i++) {
                    String url = jsonArray.getString(i);
                    listNetWork.add(url);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

            // Adding static data as before
            listNetWork.add("Viettel");
            listNetWork.add("VNPT");
            listNetWork.add("FPT");
            listNetWork.add("Mobifone");
            listNetWork.add("Vietnamobile");
            listNetWork.add("mobile");
            listNetWork.add("mefort");

            return listNetWork;
        }

        @Override
        protected void onPostExecute(List<String> listNetWork) {
            super.onPostExecute(listNetWork);
            Log.d("AAvbc", listNetWork.size() + "");

            // Creating adapter for spinner
            ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(XuLi.this, android.R.layout.simple_spinner_item, listNetWork);

            // Drop down layout style - list view with radio button
            dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

            // attaching data adapter to spinner
            spinner.setAdapter(dataAdapter);
            // Set a listener to respond when an item is selected
        }
    }

}

//    //  xử lí check status link
//    class CheckUrlsTask extends AsyncTask<List<String>, Void, Map<String, Integer>> {
//
//        @Override
//        protected Map<String, Integer> doInBackground(List<String>... params) {
//            List<String> urls = params[0];
//            Map<String, Integer> urlStatusMap = new HashMap<>();
//
//            for (String url : urls) {
//                int code = -1;
//
//                try {
//                    URL urlObj = new URL(url);
//                    HttpURLConnection connection = (HttpURLConnection) urlObj.openConnection();
//                    connection.setRequestMethod("GET");
//                    connection.connect();
//                    code = connection.getResponseCode();
//                } catch (Exception e) {
//                    // Log the error or handle it as needed
//                }
//
//                urlStatusMap.put(url, code);
//            }
//
//            return urlStatusMap;
//        }
//
//        @Override
//        protected void onPostExecute(Map<String, Integer> result) {
//            // This method runs on the UI thread, so it's safe to update UI elements here
//            StringBuilder resultMessage = new StringBuilder();
//
//            for (Map.Entry<String, Integer> entry : result.entrySet()) {
//                resultMessage.append("URL: ").append(entry.getKey())
//                        .append(" - Status Code: ").append(entry.getValue()).append("\n");
//            }
//
//            Toast.makeText(getApplicationContext(), resultMessage.toString(), Toast.LENGTH_LONG).show();
//            txt_stuss.setVisibility(View.VISIBLE);
//           txt_stuss.setText(""+resultMessage.toString());
//        }
//    }
//
//
//
//}
