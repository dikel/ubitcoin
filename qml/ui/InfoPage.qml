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
        title: i18n.tr('Informaion')
    }

    Label {
        id: address
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
			topMargin: units.gu(4)
        }
        text: "Something"
        horizontalAlignment: Label.AlignHCenter
    }
}
