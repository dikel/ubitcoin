import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
	id: homePage
	
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
        }
        text: balanceSettings.fiatBalance + " " + balanceSettings.fiat
        fontSize: "large"
        font.capitalization: Font.AllUppercase
        horizontalAlignment: Label.AlignHCenter
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
