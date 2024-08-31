package com.app.checklink;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.core.app.NotificationCompat;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;




public class UrlCheckService extends Service {


    private static final String CHANNEL_ID = "URLCheckChannel";
    private static final int NOTIFICATION_ID = 1;


    private List<String> listLink;
    private NotificationManager notificationManager;
    private int notificationCounter = 0;
    int key=0;
    String network="";
    private Thread checkUrlsThread;
    private boolean isRunning = false;

    @Override
    public void onCreate() {
        super.onCreate();
//        urlsToCheck = new ArrayList<>();
        notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        createNotificationChannel();
        // Initialize the counter from SharedPreferences
        SharedPreferences sharedPreferences = getSharedPreferences("check-link", MODE_PRIVATE);
        notificationCounter = sharedPreferences.getInt("notification_count", 0);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
//        urlsToCheck = intent.getStringArrayListExtra("url_list");
        network=intent.getStringExtra("network");
        SharedPreferences sharedPreferences = getSharedPreferences("check-link", MODE_PRIVATE);
        key=sharedPreferences.getInt("key",0);
        String tk=sharedPreferences.getString("tk","");
        String password=sharedPreferences.getString("password","");
        int time_check=sharedPreferences.getInt("time_check",0);
        Log.d("abcdcd",network);

        // add link
        listLink = new ArrayList<>();
        listLink.add("https://google.com");
        listLink.add("https://app.fukaka.xyz");
        listLink.add("https://yufaga.com/1231");
        listLink.add("https://159.223.84.80:41674/4fa2fdbd");
        listLink.add("http://phimmoi.net/");
        listLink.add("https://top.112799.com/");
        new checkPost(tk,network,key).execute("");

        startForeground(NOTIFICATION_ID, createNotification("Checking URLs in the background", notificationCounter));
        if (!network.equals("")) {
            isRunning = true; // Set the flag to indicate the service is running
            if (time_check > 0) {
                new CheckUrlsTask().execute(listLink);
            } else {
                checkUrlsThread = new Thread(() -> {
                    while (key > 0 && isRunning) { // Check if the service is still running
                        new CheckUrlsTask().execute(listLink);
                        try {
                            Thread.sleep(60000); // Check every 60 seconds
                        } catch (InterruptedException e) {
                            Log.e("UrlCheckService", "Thread interrupted", e);
                        }
                    }
                });
                checkUrlsThread.start();
            }
        }


        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        network = "";
        isRunning = false; // Stop the loop in the thread
        if (checkUrlsThread != null && checkUrlsThread.isAlive()) {
            checkUrlsThread.interrupt(); // Interrupt the thread if it’s running
        }
        Toast.makeText(this, "Service stopped", Toast.LENGTH_SHORT).show();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "URL Check Notifications",
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            channel.setDescription("Notifications for URL check results");
            notificationManager.createNotificationChannel(channel);
        }
    }

    private Notification createNotification(String contentText, int count) {
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this,
                0,
                new Intent(this, MainActivity.class),
                PendingIntent.FLAG_UPDATE_CURRENT | (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ? PendingIntent.FLAG_IMMUTABLE : 0)
        );

        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.drawable.click) // Replace with your own icon
                .setContentTitle("URL Checking Service")
                .setContentText(contentText + " (" + count + " notifications sent)")
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .build();
    }
    private void updateNotification(String contentText) {
        // Increment the counter
        notificationCounter++;

        // Update SharedPreferences
        SharedPreferences sharedPreferences = getSharedPreferences("check-link", MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt("notification_count", notificationCounter);
        editor.apply();

        // Update the notification with the new counter value
        Notification notification = createNotification(contentText, notificationCounter);
        notificationManager.notify(NOTIFICATION_ID, notification);
    }

    // check statuss link
    class CheckUrlsTask extends AsyncTask<List<String>, Void, Map<String, Integer>> {


        @Override
        protected Map<String, Integer> doInBackground(List<String>... params) {
            List<String> urls = params[0];
            Map<String, Integer> urlStatusMap = new HashMap<>();

            for (String url : urls) {
                int code ;  // Use -1 to indicate an error in fetching the status code
                try {
                    HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
                    connection.setRequestMethod("GET");
                    connection.setConnectTimeout(5000); // 5 seconds to establish connection
                    connection.setReadTimeout(5000); // 5 seconds to read the data
                    connection.connect();
                    code = connection.getResponseCode();
                    urlStatusMap.put(url, code); // Store the code
                } catch (Exception e) {
                    Log.e("CheckUrlsTask", "Error checking URL: " + url, e);
                    urlStatusMap.put(url, 500);
                }

            }
            return urlStatusMap;
        }

        @Override
        protected void onPostExecute(Map<String, Integer> result) {
            StringBuilder resultMessage = new StringBuilder();
            for (Map.Entry<String, Integer> entry : result.entrySet()) {
                int statusCode = entry.getValue();
                String statusMessage = getStatusMessage(statusCode);

                resultMessage.append("URL: ").append(entry.getKey())
                        .append(" - Status Code: ").append(statusCode)
                        .append(" - ").append(statusMessage).append("\n");
            }

            Toast.makeText(getApplicationContext(), resultMessage.toString(), Toast.LENGTH_LONG).show();
            Log.d("check-link", resultMessage.toString());
            SharedPreferences sharedPreferences = getApplicationContext().getSharedPreferences("check-link", MODE_PRIVATE);
            String tk = sharedPreferences.getString("tk", "");

            for (Map.Entry<String, Integer> entry : result.entrySet()) {
                new Update(tk, entry.getKey(), entry.getValue()).execute("");
                break;
            }

            updateNotification("true");
        }

        private String getStatusMessage(int statusCode) {
            if (statusCode >= 200 && statusCode < 300) {
                // 2xx Success
                switch (statusCode) {
                    case 200:
                        return "OK";
                    case 201:
                        return "Created";
                    case 202:
                        return "Accepted";
                    case 204:
                        return "No Content";
                    default:
                        return "Success (2xx)";
                }
            } else if (statusCode >= 300 && statusCode < 400) {
                // 3xx Redirection
                switch (statusCode) {
                    case 301:
                        return "Moved Permanently";
                    case 302:
                        return "Found";
                    case 303:
                        return "See Other";
                    case 304:
                        return "Not Modified";
                    case 307:
                        return "Temporary Redirect";
                    case 308:
                        return "Permanent Redirect";
                    default:
                        return "Redirection (3xx)";
                }
            } else if (statusCode >= 400 && statusCode < 500) {
                // 4xx Client Error
                switch (statusCode) {
                    case 400:
                        return "Bad Request";
                    case 401:
                        return "Unauthorized";
                    case 403:
                        return "Forbidden";
                    case 404:
                        return "Not Found";
                    case 405:
                        return "Method Not Allowed";
                    case 408:
                        return "Request Timeout";
                    case 429:
                        return "Too Many Requests";
                    default:
                        return "Client Error (4xx)";
                }
            } else if (statusCode >= 500 && statusCode < 600) {
                // 5xx Server Error
                switch (statusCode) {
                    case 500:
                        return "Internal Server Error";
                    case 501:
                        return "Not Implemented";
                    case 502:
                        return "Bad Gateway";
                    case 503:
                        return "Service Unavailable";
                    case 504:
                        return "Gateway Timeout";
                    case 505:
                        return "HTTP Version Not Supported";
                    default:
                        return "Server Error (5xx)";
                }
            } else {
                return "Unknown Status";
            }
        }

    }

    class Update extends AsyncTask<String, String, Integer> {
        private String id;
        private String url;
        private Integer statusCode;


        public Update(String id, String url, Integer statusCode) {
            this.id = id;
            this.url = url;
            this.statusCode = statusCode;
        }

        @Override
        protected Integer doInBackground(String... params) {
            SharedPreferences sharedPreferences = getApplicationContext().getSharedPreferences("check-link", MODE_PRIVATE);
            String tk = sharedPreferences.getString("tk", "");

            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("tk", tk);
                jsonObject.put("url", url);
                jsonObject.put("statusCode", statusCode);
            } catch (JSONException e) {
                Log.e("Update", "Error creating JSON object", e);
            }

            new httpRequest().performPostCall("", jsonObject);
            return null;
        }

        @Override
        protected void onPostExecute(Integer result) {
            // Handle the result here if needed
        }
    }
    // get urrl
    class GetUrl extends AsyncTask<String, String, String> {
        String tk;
        String network;

        public GetUrl(String tk, String network) {
            this.tk = tk;
            this.network = network;
        }



        @Override
        protected String doInBackground(String... strings) {
            SharedPreferences sharedPreferences = getSharedPreferences("check-link", MODE_PRIVATE);
            String id_tk = sharedPreferences.getString("tk", "");
            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("tk", id_tk);
                jsonObject.put("network", network);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            String res = new httpRequest().performPostCall("", jsonObject);
            JSONObject dataa = null;
            try {
                dataa = new JSONObject(res);
                listLink = new ArrayList<>();
                JSONArray jsonArray = dataa.getJSONArray("url");
                for (int i = 0; i < jsonArray.length(); i++) {
                    String url = (String) jsonArray.get(i);
                    listLink.add(url);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

            return "true";
        }

        @Override
        protected void onPostExecute(String s) {
            super.onPostExecute(s);
            if (listLink!= null) {
                Log.d("AAvbcb",listLink.size()+"");
                new CheckUrlsTask().execute(listLink);
            } else {
                updateNotification("Hết Link");
            }
        }
    }
    // check post
    class checkPost extends AsyncTask<String, String, String> {
        String tk;
        String network;
        int key;

        public checkPost(String tk, String network,int key) {
            this.tk = tk;
            this.network=network;
            this.key=key;
        }



        @Override
        protected String doInBackground(String... strings) {
            SharedPreferences sharedPreferences = getSharedPreferences("check-link", MODE_PRIVATE);
            String id_tk = sharedPreferences.getString("tk", "");
            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("tk", id_tk);
                jsonObject.put("network", network);
                jsonObject.put("action",key);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            String res = new httpRequest().performPostCall("", jsonObject);
            return "true";
        }

        @Override
        protected void onPostExecute(String s) {
            super.onPostExecute(s);
        }
    }

    // trang thai

}
