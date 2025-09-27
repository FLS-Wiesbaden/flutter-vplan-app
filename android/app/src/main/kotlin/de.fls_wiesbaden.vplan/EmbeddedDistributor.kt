package de.fls_wiesbaden.vplan

import android.content.Context
import org.unifiedpush.android.embedded_fcm_distributor.EmbeddedDistributorReceiver
import org.unifiedpush.android.embedded_fcm_distributor.Gateway

class EmbeddedDistributor: EmbeddedDistributorReceiver() {

    override val gateway = object : Gateway {
        override val vapid = "BJVlg_p7GZr_ZluA2ace8aWj8dXVG6hB5L19VhMX3lbVd3c8IqrziiHVY3ERNVhB9Jje5HNZQI4nUOtF_XkUIyI"
        val googleProjectNumber = "780435190298" // This value comes from the google-services.json
    
        override fun getEndpoint(token: String): String {
            val instance = ""
            return "https://www.fls-wiesbaden.de/FCM?v2&instance=$instance&token=$token"
        }
    }
}
