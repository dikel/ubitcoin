import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
	id: sendPage
  property string address: ''
  property string amount: ''

  header: PageHeader {
    id: header
    title: i18n.tr('Send')
  }

	Component.onCompleted: {
		if (amount) {
			python.call('backend.bch_to_fiat', [amount, settings.userCurrencyCode], function(fiat) {
				bchAmountField.text = amount
				fiatAmountField.text = fiat
			})
		}
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
    text: address
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
			right: sendToField.right
    }
    text: i18n.tr('Paste')
    width: units.gu(16)
    onClicked: {
      sendToField.text = Clipboard.data.text
    }
    color: theme.palette.normal.base
  }

  Label {
    id: amountLabel
    fontSize: "large"
    anchors {
      top: pasteButton.bottom
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
    width: units.gu(16)
    inputMethodHints: Qt.ImhFormattedNumbersOnly
		onTextChanged: {
			if(focus){
				if (text) {
					python.call('backend.bch_to_fiat', [text, settings.userCurrencyCode], function(fiat) {
						fiatAmountField.text = fiat
					})
				} else {
					fiatAmountField.text = ''
				}
			}
		}
  }

  TextField {
    id: fiatAmountField
    anchors {
      top: amountLabel.bottom
      right: sendToField.right
      topMargin: units.gu(1)
    }
    placeholderText: settings.userCurrency
    font.capitalization: Font.AllUppercase
    width: units.gu(16)
    inputMethodHints: Qt.ImhFormattedNumbersOnly
		onTextChanged: {
			if(focus){
				if (text) {
					python.call('backend.fiat_to_bch', [text, settings.userCurrencyCode], function(bch) {
						bchAmountField.text = bch
					})
				} else {
					bchAmountField.text = ''
				}
			}
		}
  }

	Button {
    id: maxButton
    anchors {
      top: bchAmountField.bottom
      topMargin: units.gu(2)
      left: sendToField.left
    }
    text: i18n.tr('Max')
    width: units.gu(16)
    color: theme.palette.normal.base
		onClicked: {
			python.call('backend.get_max_balance', [], function(amount) {
        if (amount > 0) {
					python.call('backend.bch_to_fiat', [amount, settings.userCurrencyCode], function(fiat) {
						bchAmountField.text = amount
						fiatAmountField.text = fiat
					})
				} else {
					console.log('No sufficient funds')
				}
      })
		}
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
      const amount = parseFloat(bchAmountField.text)
      python.call('backend.send', [sendToField.text, amount], function(txId) {
        console.log(txId)
      })
    }
  }
}
