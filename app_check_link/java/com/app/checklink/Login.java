package com.app.checklink;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
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
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;


public class Login extends AppCompatActivity {
    TextView txt_register;
    TextView login;
    EditText inputTk,inputPassword;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN
                , WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_login);
        mapin();
        // register
        String a="Đăng kí ngay ?";
        SpannableString span=new SpannableString(a);
        // Fixing the indices based on the actual length of the string
        span.setSpan(new RelativeSizeSpan(0.9f), 0, a.length(), 0);
        span.setSpan(new ClickableSpan() {
            @Override
            public void onClick(@NonNull View widget) {
                startActivity(new Intent(Login.this, Register.class));
            }
        }, 0, a.length(), 0);

        txt_register.setText(span);
        // Important: Make the TextView clickable
        txt_register.setMovementMethod(LinkMovementMethod.getInstance());
        // lấy thong tin tk

        String tk=inputTk.getText().toString();
        String password=inputPassword.getText().toString();
        login.setOnClickListener(new View.OnClickListener (){
            @Override
            public void onClick(View v) {
                if(tk.equals("") || password.equals("")){
                    Toast.makeText(Login.this,"Bạn chưa nhập đầy đủ thông tin",Toast.LENGTH_SHORT).show();
                }else {

                new RequestTask(tk,password).execute("");}

            }
        });



    }
    class RequestTask extends AsyncTask<String, String, String> {
        Boolean LoginStatus = false;
        String tk = "";
        String password = "";

        public RequestTask(String tk, String password){
            this.tk= tk;
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
            if (LoginStatus ==true ){

                startActivity( new Intent(Login.this,XuLi.class));
                finish();
            }else {
                Toast.makeText(Login.this,"Bạn nhập sai thông tin tài khoản",Toast.LENGTH_SHORT).show();

            }
        }
    }



    void mapin(){

        txt_register=findViewById(R.id.login_register);
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