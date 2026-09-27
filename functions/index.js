const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.broadcastNewReport = onDocumentCreated(
  "reports/{reportId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();

    const message = {
      notification: {
        title: "⚠️ Peringatan Kejahatan",
        body: `Telah dilaporkan "${data.nama_kejahatan}" di sekitar ${data.tempat}.`,
      },
      data: {
        type: "new_report",
        report_id: event.params.reportId,
        nama_kejahatan: data.nama_kejahatan ?? "",
        latitude: String(data.latitude ?? ""),
        longitude: String(data.longitude ?? ""),
        tempat: data.tempat ?? "",
        waktu: data.waktu ?? "",
        status: data.status ?? "",
      },
      topic: "vigilanter_alert",
    };

    await admin.messaging().send(message);

    // SIMPAN NOTIF KE FIRESTORE
    await admin.firestore().collection("notifications").add({
      title: message.notification.title,
      message: message.notification.body,
      type: message.data.type,
      report_id: message.data.report_id,
      tempat: message.data.tempat,
      latitude: message.data.latitude,
      longitude: message.data.longitude,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
);

 // Notifikasi saat laporan dikonfirmasi (status -> Diterima)
exports.notifyReportAccepted = onDocumentUpdated(
  "reports/{reportId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!before || !after) return;

    // hanya kirim notifikasi jika:
    // - sebelumnya bukan Diterima
    // - sekarang menjadi Diterima
    if (before.status === "Diterima" || after.status !== "Diterima") {
      return;
    }

    const message = {
      notification: {
        title: "🚨 Peringatan Darurat",
        body: `Kejahatan "${after.nama_kejahatan}" di ${after.tempat} telah TERKONFIRMASI. Hindari area dan tetap waspada.`,
      },
      data: {
        type: "report_accepted",
        report_id: event.params.reportId,
        nama_kejahatan: after.nama_kejahatan ?? "",
        latitude: String(after.latitude ?? ""),
        longitude: String(after.longitude ?? ""),
        tempat: after.tempat ?? "",
        status: after.status ?? "",
      },
      topic: "vigilanter_alert",
    };

    await admin.messaging().send(message);

    // SIMPAN NOTIF KE FIRESTORE
    await admin.firestore().collection("notifications").add({
      title: message.notification.title,
      message: message.notification.body,
      type: message.data.type,
      report_id: message.data.report_id,
      tempat: message.data.tempat,
      latitude: message.data.latitude,
      longitude: message.data.longitude,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
);