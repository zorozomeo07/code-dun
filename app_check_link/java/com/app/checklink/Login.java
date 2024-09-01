package com.app.checklink;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.LinearLayoutCompat;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.text.SpannableString;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.RelativeSizeSpan;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import pl.droidsonroids.gif.GifImageView;


public class Login extends AppCompatActivity {
    TextView txt_register;
    TextView login;
    EditText inputTk,inputPassword;
    LinearLayoutCompat lin_black;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN
                , WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_login);
        mapin();
        lin_black.setVisibility(View.GONE);

        login.setOnClickListener(new View.OnClickListener (){
            @Override
            public void onClick(View v) {
                String tk=inputTk.getText().toString();
                String password=inputPassword.getText().toString();
                Log.d("check-tk-mk",tk+"  &&  "+password);
                if(tk.equals("") || password.equals("")){
                    Toast.makeText(Login.this,"Bạn chưa nhập đầy đủ thông tin",Toast.LENGTH_SHORT).show();
                }else {

                new RequestTask(tk,password,Login.this).execute("");}
            }
        });



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
            lin_black.setVisibility(View.VISIBLE);
            new Handler().postDelayed(new Runnable (){
                @Override
                public void run() {
                    if (result == 200) {
                        Log.d("man_log", "login1");
                        editor.putString("username",tk);
                        editor.putString("password",password);
                        editor.apply();

                        context.startActivity(new Intent(context, XuLi.class));
                        if (context instanceof Activity) {
                            ((Activity) context).finish();
                        }
                    } else {
                        lin_black.setVisibility(View.GONE);
                        Toast.makeText(context, "Bạn nhập sai thông tin tài khoản", Toast.LENGTH_SHORT).show();
                    }
                }
            },1000);
        }
    }




    void mapin(){

        lin_black=findViewById(R.id.lin_black);
        login=findViewById(R.id.login);
        inputPassword=findViewById(R.id.input_password);
        inputTk=findViewById(R.id.input_tk);
    }

    @SuppressLint("MissingSuperCall")
    @Override
    public void onBackPressed() {
//        super.onBackPressed();
    }
}