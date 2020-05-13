import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {

  anchors.fill: parent
  header: PageHeader {
    id: header
    title: i18n.tr('Settings')
  }

  Label {
    id: version
    anchors {
      top: header.bottom
      left: parent.left
      right: parent.right
    }
    fontSize: "small"
    text: "Version: 0.2.1"
    horizontalAlignment: Label.AlignHCenter
  }

  Label {
    id: donationAddress
    anchors {
      top: version.bottom
      left: parent.left
      right: parent.right
			topMargin: units.gu(4)
    }
    text: "Donation address:\nbitcoincash:\nqr90ln6knmmzct8shekm27xj9xnlpes9uglhtcv5xn"
    horizontalAlignment: Label.AlignHCenter
  }

  Button {
		id: copyDonationAddressToClipboard
		anchors {
			top: donationAddress.bottom
			topMargin: units.gu(2)
      horizontalCenter: parent.horizontalCenter
		}
		text: i18n.tr('Copy to clipboard')
		onClicked: Clipboard.push("bitcoincash:qr90ln6knmmzct8shekm27xj9xnlpes9uglhtcv5xn")
		color: theme.palette.normal.positive
	}
}
