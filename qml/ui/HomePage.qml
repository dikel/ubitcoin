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
		python.call('backend.get_display_address', [], function(addr) {
			console.log('address: ' + addr);
        })
	}
	
    Label {
        id: balance
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }
        text: i18n.tr('Balance') + ': 0.0 BCH'
        fontSize: "large"
        horizontalAlignment: Label.AlignHCenter
    }
}
