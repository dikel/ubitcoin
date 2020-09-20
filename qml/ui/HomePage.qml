import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
	id: homePage

	property ListModel txsModel: ListModel {}
	property ListModel tempTxsModel: ListModel {}

  anchors.fill: parent
  header: PageHeader {
    id: header
    title: i18n.tr('uBitcoin')

    trailingActionBar.actions: [
			Action {
				text: "Settings"
				iconName: "settings"
				onTriggered: {
					pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
				}
			},
			Action {
				text: "Receive"
				iconName: "import"
				onTriggered: {
					pageStack.push(Qt.resolvedUrl("ReceivePage.qml"))
				}
			}
    ]
  }

	function updateTransactionList() {
		python.call('backend.get_all_transaction_ids', [], function(txs) {
			if (!txs) {
				updatingIndicator.running = false
				return
			}

			var last = txs[0]
			if (txs.length > txsModel.count || last !== txsModel.get(0).id) {
				for (var txid in txs.reverse()) {
					python.call('backend.get_transaction_details', [txs[txid]], function(tx) {
						var parsedTx = JSON.parse(tx)
						tempTxsModel.insert(0, parsedTx)

						// Update the model only after the last TX to improve the UX
						if (parsedTx.id === last) {
							txsModel.clear()
							for (var i = 0; i < tempTxsModel.count; i++) {
								txsModel.set(i, tempTxsModel.get(i))
							}
							updatingIndicator.running = false
							tempTxsModel.clear()
							saveTxsModel()
						}
					})
				}
			} else {
				updatingIndicator.running = false
			}
		})
	}

	function saveTxsModel() {
		var model = []
		for (var i = 0; i < txsModel.count; i++) {
			model.push(txsModel.get(i))
		}
		settings.txStore = JSON.stringify(model)
		updatingIndicator.running = false
	}

	Component.onCompleted: {
		if (settings.txStore) {
			var model = JSON.parse(settings.txStore)
			for (var i = 0; i < model.length; i++) {
				txsModel.append(model[i])
			}
		}
    python.call('backend.get_balance', [settings.userCurrencyCode], function(bal) {
			settings.bchBalance = bal[0]
			settings.fiatBalance = bal[1]
		})

		updateTransactionList()
	}

  Label {
    id: bchBalanceLabel
    anchors {
      top: header.bottom
      left: parent.left
      right: parent.right
    }
    text: settings.bchBalance + " BCH"
    fontSize: "x-large"
    horizontalAlignment: Label.AlignHCenter
  }

  Label {
    id: fiatBalanceLabel
    anchors {
      top: bchBalanceLabel.bottom
      left: parent.left
      right: parent.right
			bottomMargin: units.gu(2)
    }
    text: settings.fiatBalance + " " + settings.userCurrency
    fontSize: "large"
    font.capitalization: Font.AllUppercase
    horizontalAlignment: Label.AlignHCenter
  }

	ActivityIndicator {
	  id: updatingIndicator
	  anchors {
	    top: fiatBalanceLabel.bottom
	    left: parent.left
	    right: parent.right
	  }
		running: true
	  }

  UbuntuListView {
		id: txListView
		anchors {
			top: updatingIndicator.bottom
      left: parent.left
      right: parent.right
      bottom: parent.bottom
			bottomMargin: units.gu(4)
		}
		clip: true
		currentIndex: -1
		model: txsModel
		delegate: ListItem {
			Label {
				id: txLabel
				anchors {
					top: parent.top
					bottom: parent.bottom
				}
				text: address.split(':')[1].substr(0, 20) + '..'
				verticalAlignment: Label.AlignVCenter
			}

			Label {
				id: txBchBalance
				anchors {
					right: parent.right
					rightMargin: units.gu(1)
				}
				text: (!!is_sent ? "-" : "+") + amount
				color: (!!is_sent ? "red" : "green")
				fontSize: "large"
			}

			Label {
				anchors{
					top: txBchBalance.bottom
					right: txBchBalance.right
				}
				font.capitalization: Font.AllUppercase
				Component.onCompleted: {
			    python.call('backend.bch_to_fiat', [amount, settings.userCurrencyCode], function(bal) {
						text = bal + " " + settings.userCurrency
					})
				}
			}

			trailingActions: ListItemActions {
				actions: [
					Action {
						id: externalLinkAction
						iconName: "external-link"
						text: i18n.tr("Open")

						onTriggered: {
							Qt.openUrlExternally("https://explorer.bitcoin.com/bch/tx/" + id)
						}
					}
				]
			}
		}
  }

  BottomEdge {
		id: bottomEdge
		hint {
			enabled: visible
			visible: bottomEdge.enabled
			text: i18n.tr("Send")
			status: BottomEdgeHint.Active
		}
		contentUrl: Qt.resolvedUrl("SendPage.qml")
		height: homePage.height
		preloadContent: true

		Binding {
			target: bottomEdge.contentItem
			property: "width"
			value: bottomEdge.width
		}

		Binding {
			target: bottomEdge.contentItem
			property: "height"
			value: bottomEdge.height
		}
  }

	// Move to background service and use socket
  // Timer {
  //   id: balanceTimer
  //   running: true
  //   repeat: true
  //   interval: 10000
  //   onTriggered: {
	// 		updatingIndicator.running = true
	// 		python.call('backend.get_balance', [balanceSettings.fiat], function(bal) {
	// 			balanceSettings.bchBalance = bal[0]
	// 			balanceSettings.fiatBalance = bal[1]
	// 			updatingIndicator.running = false
	// 		})
  //   }
  // }
}
