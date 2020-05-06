import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
	id: homePage
	
	property ListModel txsModel: ListModel {}
	
	Settings {
		id: balanceSettings
		property string fiat: "usd"
		property string bchBalance: "0.0"
		property string fiatBalance: "0.0"
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
        python.call('backend.get_balance', [balanceSettings.fiat], function(bal) {
			balanceSettings.bchBalance = bal[0]
			balanceSettings.fiatBalance = bal[1]
		})
		python.call('backend.get_all_transaction_ids', [], function(txs) {
			const txsDiff = txs.length - txsModel.count
			const newTxs = txs.slice(0, txsDiff)
			console.log(newTxs)
			for (var txid in newTxs.reverse()) {
				python.call('backend.get_transaction_details', [newTxs[txid]], function(tx) {
					console.log(tx)
					txsModel.insert(0, JSON.parse(tx))
				})
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
		anchors {
			top: fiatBalanceLabel.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
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
