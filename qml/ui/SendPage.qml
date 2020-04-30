import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
    header: PageHeader {
        id: header
        title: i18n.tr('Send')
    }
	Rectangle {
        anchors.fill: parent
        color: Theme.palette.normal.background
    }
	Component.onCompleted: {
		python.call('backend.get_address', [], function(addr) {
			console.log('fff');
        })
	}
	Label {
        id: sendToLabel
        fontSize: "large"
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
			topMargin: units.gu(2)
			leftMargin: units.gu(4)
        }
        text: i18n.tr('Send To:')
    }
	TextArea {
		id: sendToField
		placeholderText: i18n.tr('bitcoincash:')
		autoSize: true
		anchors {
			top: sendToLabel.bottom
            left: parent.left
            right: parent.right
			leftMargin: units.gu(4)
			rightMargin: units.gu(4)
			topMargin: units.gu(1)
		}
	}
	Button {
		id: pasteButton
		anchors {
			top: sendToField.bottom
			topMargin: units.gu(2)
			left: sendToField.left
		}
		text: i18n.tr('Paste')
		width: units.gu(16)
		onClicked: sendToField.text = Clipboard.data.text
		color: theme.palette.normal.positive
	}
	
	Button {
		id: scanButton
		anchors {
			top: sendToField.bottom
			topMargin: units.gu(2)
			right: sendToField.right
		}
		text: i18n.tr('Scan QR')
		width: units.gu(16)
		onClicked: console.log("Not supported yet")
		color: theme.palette.normal.base
	}
	Label {
        id: amountLabel
        fontSize: "large"
        anchors {
            top: scanButton.bottom
            left: parent.left
            right: parent.right
			topMargin: units.gu(4)
			leftMargin: units.gu(4)
        }
        text: i18n.tr('Amount:')
    }
    TextField {
		id: bchAmountField
		anchors {
			top: amountLabel.bottom
            left: sendToField.left
			topMargin: units.gu(1)
		}
		placeholderText: 'BCH'
		text: ""
		width: units.gu(16)
		onTextChanged: console.log("Text has changed to:", text)
		inputMethodHints: Qt.ImhFormattedNumbersOnly
    }
    TextField {
		id: fiatAmountField
		anchors {
			top: amountLabel.bottom
            right: sendToField.right
			topMargin: units.gu(1)
		}
		placeholderText: fiat
        font.capitalization: Font.AllUppercase
		text: ""
		width: units.gu(16)
		onTextChanged: console.log("Text has changed to:", text)
		inputMethodHints: Qt.ImhFormattedNumbersOnly
    }
}
