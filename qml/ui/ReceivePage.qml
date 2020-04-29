import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
	property string stringAddress

	anchors.fill: parent
    header: PageHeader {
        id: header
        title: i18n.tr('Receive')
    }
    
	Component.onCompleted: {
		python.call('backend.get_address', [], function(addr) {
			console.log('address: ' + addr);
            stringAddress = addr[0];
            qrAddress.source = addr[1];
        })
	}
	
    Label {
        id: address
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }
        text: stringAddress.replace(":", ":\n")
        horizontalAlignment: Label.AlignHCenter
    }
    
    Rectangle {
    	id: qrWrapper
		anchors {
			top: address.bottom
			topMargin: units.gu(4)
            horizontalCenter: parent.horizontalCenter
		}
        width: units.gu(30)
        height: units.gu(30)
		color: "white"
		border.color: "black"
		border.width: 2
		radius: 20
			
		Image {
			id: qrAddress
			anchors.fill: parent
			sourceSize.width: 1024
			sourceSize.height: 1024
		}
	}
	
	Button {
		id: copyToClipboard
		anchors {
			top: qrWrapper.bottom
			topMargin: units.gu(4)
            horizontalCenter: parent.horizontalCenter
		}
		text: i18n.tr('Copy to clipboard')
		onClicked: Clipboard.push(stringAddress)
		color: theme.palette.normal.positive
	}
}
