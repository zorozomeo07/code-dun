package com.app.checklink;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

public class Register extends AppCompatActivity {
    TextView register;
    EditText inputTk;
    EditText inputPassword01;
    EditText inputPassword02;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN
                , WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_register);
        mimap();
        String tk=inputTk.toString();
        String pass01=inputPassword01.getText().toString();
        String pass02=inputPassword02.getText().toString();
        register.setOnClickListener(new View.OnClickListener (){
            @Override
            public void onClick(View v) {
                if(tk.equals("")||pass01.equals("")||pass02.equals("") || pass01.contains(" ")|| pass02.contains(" ")|| tk.contains(" ")){
                    Toast.makeText(Register.this,"Vui lòng nhập đầy đủ thông tin , không để khoảng cách trống!",Toast.LENGTH_SHORT).show();
                }else {
                    if(pass01.equals(""+pass02)){
                        Toast.makeText(Register.this,"Mật khẩu nhập không trùng khớp !",Toast.LENGTH_SHORT).show();

                    }else {
                        Toast.makeText(Register.this,"Tạo tài khoản thành công",Toast.LENGTH_SHORT).show();
                        new RequestTask(tk,pass01).execute("");
                    }
                }
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
                startActivity( new Intent(Register.this,XuLi.class));
                finish();
            }else {
                Toast.makeText(Register.this,"Tài khoản đã tồn tại. ",Toast.LENGTH_SHORT).show();

            }
        }
    }
    void mimap(){
        register=findViewById(R.id.register);
        inputTk=findViewById(R.id.input_tk);
        inputPassword01=findViewById(R.id.input_password01);
        inputPassword02=findViewById(R.id.input_password02);

    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }
}