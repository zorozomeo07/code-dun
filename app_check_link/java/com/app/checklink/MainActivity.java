package com.app.checklink;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;

import org.json.JSONException;
import org.json.JSONObject;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN
                , WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main);
        SharedPreferences sharedPreferences=getSharedPreferences("check-link",MODE_PRIVATE);
        String Tk=sharedPreferences.getString("tk","");
        String password=sharedPreferences.getString("password","");
        if(!Tk.equals("")){
            new RequestTask(Tk,password).execute("");
        }else {
           new Handler().postDelayed(new Runnable (){
               @Override
               public void run() {
                   startActivity(new Intent(MainActivity.this,XuLi.class));
               }
           },1200);
        }
    }

    @SuppressLint("MissingSuperCall")
    @Override
    public void onBackPressed() {
//        super.onBackPressed();
    }
    class RequestTask extends AsyncTask<String, String, String> {
        Boolean LoginStatus = false;
        String tk= "";
        String password = "";


        public RequestTask(String tk, String password){
            this.tk = tk;
            this.password=password;
        }
        @Override
        protected String doInBackground(String... uri) {
            JSONObject user =  new JSONObject();
            try {
                user.put("tk",this.tk);
                user.put("password",this.password);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            String res = new httpRequest().performPostCall("https://nanoit.info/api/usernameSMS/login.php",user);
            Log.d("Res: ",res);

            JSONObject obj = null;
            try {
                obj = new JSONObject(res);
                if (obj.getString("status").equals("success")){
                    JSONObject userDATA = obj.getJSONObject("arr_req");
                    SharedPreferences sharedPreferences = getSharedPreferences("check-link",MODE_PRIVATE);
                    SharedPreferences.Editor editor = sharedPreferences.edit();
                    editor.putString("tk", userDATA.getString("tk"));
                    editor.putString("password", userDATA.getString("password"));
                    editor.putString("check_red", userDATA.getString("check_red"));
                    // luu biến time delay
                    editor.putInt("time_check", Integer.parseInt(userDATA.getString("time_check")));
                    editor.commit();
                    LoginStatus= true;
                }else{
                    LoginStatus= false;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                LoginStatus= false;
            }
            return "true";
        }

        @Override
        protected void onPostExecute(String result) {
            super.onPostExecute(result);
            SharedPreferences sharedPreferences = getSharedPreferences("check-link",Context.MODE_PRIVATE);
            int timeSession = sharedPreferences.getInt("time_check", 0);
            Log.d("time-check",timeSession+"");
            if (LoginStatus ==true ){

                startActivity( new Intent(MainActivity.this,XuLi.class));
                finish();
            }else {
                startActivity( new Intent(MainActivity.this,Login.class));
                finish();

            }
        }
    }


}