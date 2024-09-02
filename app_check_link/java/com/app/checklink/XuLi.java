package com.app.checklink;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.annotation.SuppressLint;
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
    ImageView go_out;
    String tk;
    String network = "";

    int key = 0;
    Spinner spinner;
    LinearLayout lin_network;
    List<String> listNetWork =new ArrayList<>();
    SharedPreferences sharedPreferences;
    SharedPreferences.Editor editor;
    private static final int REQUEST_CODE_POST_NOTIFICATIONS = 1001;
    String networktype="";
    String userID;

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
        editor = sharedPreferences.edit();
        // check net
        key=sharedPreferences.getInt("key",0);
        // du lieu

        tk = sharedPreferences.getString("username", "admin123");
        tai_khoan.setText("Tk : " + tk);
        txt_network.setText("Network : ......");
        networktype=NetworkUtil.getNetworkType(XuLi.this);
        spinner = (Spinner) findViewById(R.id.spinner);
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
//                Toast.makeText(XuLi.this, "Bạn đã chọn nhà mạng " + network + " !", Toast.LENGTH_SHORT).show();
                editor.putString("network",network);
                editor.commit();
                txt_network.setText("Network : " + network);
                network=network +" - "+networktype;
                Log.d("abcdc",network);
                new UpdateNetwork(tk,network).execute();
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
//                        new UrlCheckService.checkPost(tk,network,key).execute();
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
                key=1;
                txt_check_link.setVisibility(View.GONE);
                txt_stop.setVisibility(View.VISIBLE);
                Intent serviceIntent = new Intent(XuLi.this, UrlCheckService.class);
                serviceIntent.putExtra("network",network);
                startService(serviceIntent);
                txt_stuss.setVisibility(View.VISIBLE);
                // push key
                editor.putInt("key", 1);
                editor.commit();
            }
        });
        // txt stop
        txt_stop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                key=0;
//                new UrlCheckService.checkPost(tk,network,key).execute();
                Intent serviceIntent = new Intent(XuLi.this, UrlCheckService.class);
                stopService(serviceIntent);
                txt_stop.setVisibility(View.GONE);
                lin_network.setVisibility(View.VISIBLE);
                txt_chon.setVisibility(View.VISIBLE);
                txt_stuss.setVisibility(View.GONE);
                editor.putInt("key", 0);
                editor.commit();
                txt_network.setText("Network :..... " );
               // Toast.makeText(XuLi.this,"Dừng check link thành công !",Toast.LENGTH_SHORT).show();
            }
        });
        go_out.setOnClickListener(new View.OnClickListener (){
            @Override
            public void onClick(View v) {
                key=sharedPreferences.getInt("key",0);
                if(key>0){
                    Toast.makeText(XuLi.this,"Bạn cần dừng check link trước khi đăng xuất TK !",Toast.LENGTH_SHORT).show();
                }else {
                    out();
                }

            }
        });
        if(key>0){
            txt_check_link.setVisibility(View.GONE);
            txt_stop.setVisibility(View.VISIBLE);
            txt_stuss.setVisibility(View.VISIBLE);
            lin_network.setVisibility(View.GONE);
            txt_chon.setVisibility(View.GONE);
            txt_network.setVisibility(View.VISIBLE);
            network=sharedPreferences.getString("network","");
            txt_network.setText("Network : " + network);
        }else {
            lin_network.setVisibility(View.VISIBLE);
            txt_network.setText("Network :..... " );
        }

    }

    @SuppressLint("MissingSuperCall")
    @Override
    public void onBackPressed() {
        finishAffinity();
    }
    void out(){
        AlertDialog.Builder alerdialog=new AlertDialog.Builder(XuLi.this);
        alerdialog.setTitle("Bạn có chắc chắn muốn đăng xuất tài khoản ?");
        alerdialog.setPositiveButton("Đồng ý",new DialogInterface.OnClickListener (){
            @Override
            public void onClick(DialogInterface dialog, int which) {
                // xoá tk , mk đã lưu
                editor.clear();
                editor.commit();
                // dừng sevice lại
                Intent serviceIntent = new Intent(XuLi.this, UrlCheckService.class);
                stopService(serviceIntent);
                // chuyển về trang login đăng nhập lại
                startActivity(new Intent(XuLi.this,Login.class));
                Toast.makeText(XuLi.this,"Đăng xuất tài khoản thành công !",Toast.LENGTH_SHORT).show();
            }
        });
        alerdialog.setNegativeButton("Huỷ",new DialogInterface.OnClickListener (){
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });
        alerdialog.show();
    }


    void mimap() {
        go_out=findViewById(R.id.go_out);
        tai_khoan = findViewById(R.id.tk);
        txt_network = findViewById(R.id.txt_network);
        txt_chon = findViewById(R.id.chose);
        txt_check_link = findViewById(R.id.check);
        txt_stop = findViewById(R.id.stop);
        reset = findViewById(R.id.reset);
        txt_stuss = findViewById(R.id.stus_tb);
        lin_network = findViewById(R.id.network_chose);
        go_out=findViewById(R.id.go_out);
    }
    // push network
    class UpdateNetwork extends  AsyncTask<String,String,Integer>{
        String tka;
        String networka;
       public UpdateNetwork(String tk,String network){
           this.tka=tk;
           this.networka=network;
       }
        @Override
        protected Integer doInBackground(String... strings) {
           JSONObject jsonObject=new JSONObject();
            try {
                jsonObject.put("username",tka);
                jsonObject.put("network",networka);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            String res=new httpRequest().performPostCall("https://api.techz.fun/update-network.php",jsonObject);
            int status=0;

            JSONObject data=null;
            try {

                data=new JSONObject(res);
                status=data.getInt("status");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            Log.d("response_network",res+"");
            return status;
        }

        @Override
        protected void onPostExecute(Integer result) {
            super.onPostExecute(result);
            Log.d("result-check-link",result+"");
            if(result==200){
                Toast.makeText(XuLi.this, "Bạn đã chọn nhà mạng thành công !", Toast.LENGTH_SHORT).show();
                lin_network.setVisibility(View.GONE);
                txt_chon.setVisibility(View.GONE);
                txt_check_link.setVisibility(View.VISIBLE);
                Log.d("result-check-link","true network: "+ result +" aaa  "+tka +"   "+networka);
            }else {
                Toast.makeText(XuLi.this,"Update thất bại , vui lòng chọn lại nhà mạng !",Toast.LENGTH_SHORT).show();
                Log.d("result-check-link","false network: "+ result+" aaa  "+tka +"   "+networka);
            }
        }
    }
    // xử lí lấy network
    class GetNetWork extends AsyncTask<String, Void, List<String>> {
        String tk;
        List<String> listNetWork;

        public GetNetWork(String tk) {
            this.tk = tk;
            this.listNetWork = new ArrayList<>();
        }

        @Override
        protected List<String> doInBackground(String... strings) {
            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("username", tk);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            String res = new httpRequest().performPostCall("https://api.techz.fun/get-list-network.php", jsonObject);
            try {
                JSONObject dataa = new JSONObject(res);
                JSONArray jsonArray = dataa.getJSONArray("list_network");
                for (int i = 0; i < jsonArray.length(); i++) {
                    String url = jsonArray.getString(i);
                    listNetWork.add(url);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
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
