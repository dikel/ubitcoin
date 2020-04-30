import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
	id: homePage
	property string fiat: "usd"

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
        python.call('backend.get_balance', [fiat], function(bal) {
			bchBalance.text = bal[0] + " BCH"
			fiatBalance.text = bal[1] + " " + fiat
		})
	}
	
    Label {
        id: bchBalance
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }
        text: '0.0 BCH'
        fontSize: "x-large"
        horizontalAlignment: Label.AlignHCenter
    }
    
    Label {
        id: fiatBalance
        anchors {
            top: bchBalance.bottom
            left: parent.left
            right: parent.right
        }
        text: '0.0 ' + fiat
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
		preloadContent: false
		
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
			python.call('backend.get_balance', [fiat], function(bal) {
				bchBalance.text = bal[0] + " BCH"
				fiatBalance.text = bal[1] + " " + fiat
			})
        }
    }
}
