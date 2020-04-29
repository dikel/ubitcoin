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
	TextField {
		placeholderText: i18n.tr('Address')
		anchors {
			top: header.bottom
            horizontalCenter: parent.horizontalCenter
		}
	}
}
