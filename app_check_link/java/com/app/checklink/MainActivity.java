package com.app.checklink;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.app.Activity;
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
        String Tk=sharedPreferences.getString("username","");

        String password=sharedPreferences.getString("password","");
        if(!Tk.equals("")){
            new RequestTask(Tk,password,MainActivity.this).execute("");
        }else {
           new Handler().postDelayed(new Runnable (){
               @Override
               public void run() {
                   startActivity(new Intent(MainActivity.this,Login.class));
               }
           },1200);
        }
    }

    @SuppressLint("MissingSuperCall")
    @Override
    public void onBackPressed() {
//        super.onBackPressed();
    }
    class RequestTask extends AsyncTask<String, String, Integer> {
        String tk = "";
        String password = "";
        Context context;

        public RequestTask(String tk, String password, Context context) {
            this.tk = tk;
            this.password = password;
            this.context = context;
        }

        @Override
        protected Integer doInBackground(String... strings) {
            JSONObject user = new JSONObject();
            try {
                user.put("username", this.tk);
                user.put("password", this.password);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            String res = new httpRequest().performPostCall("https://api.techz.fun/login.php", user);
            Log.d("Res: ", res + "  777   " + tk + " bb  " + password);
            int status = 0;

            try {
                JSONObject obj = new JSONObject(res);
                if (obj.getInt("status") == 200) {
                    SharedPreferences sharedPreferences = context.getSharedPreferences("check-link", Context.MODE_PRIVATE);
                    SharedPreferences.Editor editor = sharedPreferences.edit();
                    status = obj.getInt("status");
                    int loopTime = obj.getInt("loop_time");
                    editor.putString("userID", obj.getString("userID"));
                    editor.putString("username", obj.getString("username"));
                    // save loop time
                    editor.putInt("loop_time", loopTime);
                    editor.apply();
                    Log.d("RequestTask", "Preferences saved: loop_time = " + sharedPreferences.getInt("loop_time", 0));
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
            return status;
        }

        @Override
        protected void onPostExecute(Integer result) {
            super.onPostExecute(result);
            SharedPreferences sharedPreferences = context.getSharedPreferences("check-link", Context.MODE_PRIVATE);
            int timeSession = sharedPreferences.getInt("loop_time", 0);
            SharedPreferences.Editor editor=sharedPreferences.edit();
            Log.d("time-check", timeSession + "   &&   " + result);
            if (result == 200) {
                Log.d("man_log", "login1");
                context.startActivity(new Intent(context, XuLi.class));
                if (context instanceof Activity) {
                    ((Activity) context).finish();
                }
            } else {
                Log.d("man_log","m2");
                startActivity( new Intent(MainActivity.this,Login.class));
                finish();

            }
        }
    }


}