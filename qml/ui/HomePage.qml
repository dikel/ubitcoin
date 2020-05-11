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

	Settings {
		id: balanceSettings
		property string fiat: "usd"
		property string bchBalance: "0.0"
		property string fiatBalance: "0.0"
		property string txStore: "[]"
	}

  anchors.fill: parent
  header: PageHeader {
    id: header
    title: i18n.tr('uBitcoin')

    trailingActionBar.actions: [
			Action {
				text: "Informatin"
				iconName: "info"
				onTriggered: {
					pageStack.push(Qt.resolvedUrl("InfoPage.qml"))
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

	Component.onCompleted: {
		if (balanceSettings.txStore) {
			var model = JSON.parse(balanceSettings.txStore)
			for (var i = 0; i < model.length; i++) {
				txsModel.append(model[i])
			}
		}
    python.call('backend.get_balance', [balanceSettings.fiat], function(bal) {
			balanceSettings.bchBalance = bal[0]
			balanceSettings.fiatBalance = bal[1]
		})

		python.call('backend.get_all_transaction_ids', [], function(txs) {
			var last = txs[0]
			if (last !== txsModel.get(0)) {
				for (var txid in txs.reverse()) {
					python.call('backend.get_transaction_details', [txs[txid]], function(tx) {
						var parsedTx = JSON.parse(tx)
						tempTxsModel.insert(0, parsedTx)
						if (parsedTx.id === last) {
							txsModel = tempTxsModel
							txListView.currentIndex = -1

							var model = []
							for (var i = 0; i < txsModel.count; i++) {
								model.push(txsModel.get(i))
							}
							balanceSettings.txStore = JSON.stringify(model)
						}
					})
				}
			}
		})
	}

  Label {
    id: bchBalanceLabel
    anchors {
      top: header.bottom
      left: parent.left
      right: parent.right
    }
    text: balanceSettings.bchBalance + " BCH"
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
    text: balanceSettings.fiatBalance + " " + balanceSettings.fiat
    fontSize: "large"
    font.capitalization: Font.AllUppercase
    horizontalAlignment: Label.AlignHCenter
  }

  UbuntuListView {
		id: txListView
		anchors {
			top: fiatBalanceLabel.bottom
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
				text: address.split(':')[1].substr(0, 20) + '..'
			}

			Label {
				anchors.top: txLabel.bottom
				text: (!!is_sent ? "Sent" : "Received")
			}

			Label {
				id: txBchBalance
				anchors{
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
			    python.call('backend.bch_to_fiat', [amount, balanceSettings.fiat], function(bal) {
						text = bal + " " + balanceSettings.fiat
					})
				}
			}

			leadingActions: ListItemActions {
				actions: [
					Action {
						id: deleteAction
						objectName: "deleteAction"
						iconName: "delete"
						text: i18n.tr("Delete")
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

  Timer {
    id: balanceTimer
    running: true
    repeat: true
    interval: 10000
    onTriggered: {
			python.call('backend.get_balance', [balanceSettings.fiat], function(bal) {
				balanceSettings.bchBalance = bal[0]
				balanceSettings.fiatBalance = bal[1]
			})
    }
  }
}
