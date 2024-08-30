package com.app.checklink;//package com.app.checklink;

import static android.content.Context.WIFI_AWARE_SERVICE;
import static android.content.Context.WIFI_SERVICE;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.DhcpInfo;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.wifi.SupplicantState;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.widget.TextView;
import android.widget.Toast;

import java.net.InetAddress;
import java.net.UnknownHostException;

public class NetworkUtil {

    public static String getNetworkType(Context context) {
        ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        String networkType = "Unknown";

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            NetworkCapabilities networkCapabilities = connectivityManager.getNetworkCapabilities(connectivityManager.getActiveNetwork());
            if (networkCapabilities != null) {
                if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                    networkType = "WiFi";
                } else if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                    networkType = "Mobile Data";
                }
            }
        } else {
            NetworkInfo activeNetwork = connectivityManager.getActiveNetworkInfo();
            if (activeNetwork != null) {
                if (activeNetwork.getType() == ConnectivityManager.TYPE_WIFI) {
                    networkType = "WiFi";
                } else if (activeNetwork.getType() == ConnectivityManager.TYPE_MOBILE) {
                    networkType = "Mobile Data";
                }
            }
        }
        return networkType;
    }

    public static void updateNetworkTypeText(Context context, TextView txt) {
        String networkType = getNetworkType(context);
        if (txt != null) {
            txt.setText("Network Type: " + networkType);
        }
    }

//    public static String getMobileCarrierName(Context context) {
//        TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
//        String carrierName = telephonyManager.getNetworkOperatorName();
//        return carrierName != null ? carrierName : "Unknown Carrier";
//    }
//    public static String getMobileCarrierName(Context context) {
//        TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
//
//        String carrierName = telephonyManager.getSimOperatorName();
//        if (carrierName == null || carrierName.isEmpty()) {
//            carrierName = telephonyManager.getNetworkOperatorName();
//        }
//        if (carrierName == null || carrierName.isEmpty() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//            CharSequence carrierNameCharSeq = null;
//            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
//                carrierNameCharSeq = telephonyManager.getSimCarrierIdName();
//            }
//            carrierName = carrierNameCharSeq != null ? carrierNameCharSeq.toString() : null;
//        }
//
//        return carrierName != null && !carrierName.isEmpty() ? carrierName : "Unknown Carrier";
//    }
//
//    public static String getWifiSSID(Context context) {
//        WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
//        WifiInfo wifiInfo = wifiManager.getConnectionInfo();
//
//        if (wifiInfo != null && wifiInfo.getSupplicantState() == SupplicantState.COMPLETED) {
//            String ssid = wifiInfo.getSSID();
//            return ssid != null && !ssid.isEmpty() ? ssid : "Unknown SSID";
//        }
//        return "Unknown SSID";
//    }
//
//
//
//    public static String getNetworkDetails(Context context, TextView txt) {
//        String networkType = getNetworkType(context);
//        String result;
//
//        if (networkType.equals("WiFi")) {
//        String ssid = getWifiSSID(context);
//
//            result = "WiFi : " + ssid;
//        } else if (networkType.equals("Mobile Data")) {
//            String carrierName = getMobileCarrierName(context);
//            result = "Mobile Data :  " + carrierName ;
//        } else {
//            result = "Not connected to any network";
//        }
//
//        Log.d("AAA-test", result);
//        Toast.makeText(context,"  "+ result,Toast.LENGTH_SHORT).show();
//        txt.setText("net work: "+networkType +"\n"+result);
//        return result;
//    }
}


