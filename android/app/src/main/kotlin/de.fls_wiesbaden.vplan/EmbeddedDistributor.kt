package de.fls_wiesbaden.vplan

import android.content.Context
import org.unifiedpush.android.foss_embedded_fcm_distributor.EmbeddedDistributorReceiver

class EmbeddedDistributor: EmbeddedDistributorReceiver() {

    override val googleProjectNumber = "780435190298" // This value comes from the google-services.json

    override fun getEndpoint(context: Context, token: String, instance: String): String {
        // This returns the endpoint of your FCM Rewrite-Proxy
        return "https://www.fls-wiesbaden.de/FCM?v2&instance=$instance&token=$token"
    }
}
