import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {

	function isAddressValid(callback) {
		python.call('backend.is_address_valid', [sendToField.text], function(isValid) {
			if(isValid) {
				sendToField.color = theme.palette.normal.baseText
			} else {
				sendToField.color = "red"
			}
			if(!!callback) callback(isValid)
		})
	}

  header: PageHeader {
    id: header
    title: i18n.tr('Send')
  }

	Rectangle {
    anchors.fill: parent
    color: Theme.palette.normal.background
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
		onTextChanged: {
			if(focus) {
				color = theme.palette.normal.baseText
			}
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
		onClicked: {
			sendToField.text = Clipboard.data.text
			isAddressValid()
		}
		color: theme.palette.normal.base
	}

	// Probably open Tagger in the future
	Button {
		id: scanButton
		anchors {
			top: sendToField.bottom
			topMargin: units.gu(2)
			right: sendToField.right
		}
		text: i18n.tr('Scan QR')
		width: units.gu(16)
		enabled: false
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
		onTextChanged: {
			if(focus) {
				color = theme.palette.normal.baseText
				if(text){
					python.call('backend.bch_to_fiat', [text, balanceSettings.fiat], function(fiat) {
						fiatAmountField.text = fiat
					})
				} else {
					fiatAmountField.text = ""
				}
			}
		}
		inputMethodHints: Qt.ImhFormattedNumbersOnly
  }

  TextField {
		id: fiatAmountField
		anchors {
			top: amountLabel.bottom
      right: sendToField.right
			topMargin: units.gu(1)
		}
		placeholderText: balanceSettings.fiat
    font.capitalization: Font.AllUppercase
		text: ""
		width: units.gu(16)
		onTextChanged: {
			if(focus) {
				color = theme.palette.normal.baseText
				if(text){
					python.call('backend.fiat_to_bch', [text, balanceSettings.fiat], function(bch) {
						bchAmountField.text = bch
					})
				} else {
					bchAmountField.text = ""
				}
			}
		}
		inputMethodHints: Qt.ImhFormattedNumbersOnly
    }

  Button {
		id: sendAllButton
		anchors {
			top: bchAmountField.bottom
			topMargin: units.gu(2)
			left: sendToField.left
		}
		text: i18n.tr('Send all')
		width: units.gu(16)
		enabled: false
		color: theme.palette.normal.base
	}

	Button {
		id: sendButton
		anchors {
			top: fiatAmountField.bottom
			topMargin: units.gu(2)
			right: sendToField.right
		}
		text: i18n.tr('Send')
		width: units.gu(16)
		color: theme.palette.normal.positive
		onClicked: {
			isAddressValid(function(isValid) {
				const amount = parseFloat(bchAmountField.text)
				if (isValid && !!amount && amount > 0 && amount < balanceSettings.bchBalance && !sendTimer.running) {
					python.call('backend.send', [sendToField.text, amount], function(txId) {
						if(!!txId) {
							sendTimer.txId = txId
							sendTimer.running = true
							bottomEdge.collapse()
						} else {
							console.log("tx error")
						}
					})
				}
			})
		}
	}

	Timer {
    id: sendTimer
		running: false
		repeat: false
		interval: 2000

		property var txId

		onTriggered: {
			python.call('backend.get_transaction_details', [txId], function(tx) {
				txsModel.insert(0, JSON.parse(tx))
				saveTxsModel()
				// If there are more than 10 TXs remove the last
				if (!!txsModel.get(10)) {
					txsModel.remove(10)
				}
			})
		}
	}
}
