const vplanAppId = "de.fls_wiesbaden.vplan";
const vplanLoggerId = vplanAppId;

// push notifications
var vplanNotifyInstance = "$vplanAppId.ntfy_instance";
const featureAndroidBytesMessage =
    "org.unifiedpush.android.distributor.feature.BYTES_MESSAGE";

// Tasks
const vplanRefreshTask = "$vplanAppId.refreshTask";

// Notification channels
const vplanNewEntriesChannelId = "$vplanAppId.notify.newEntries";
const vplanNewEntriesChannelName = "Neue Vertretungen";
const vplanNewEntriesChannelDescription = "Benachrichtigung über neue Einträge zu den eingestellten Filtern.";