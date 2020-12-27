import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
  id: homePage

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
      }
    ]
  }

	ActivityIndicator {
    id: updatingIndicator
    anchors {
      top: header.bottom
      left: parent.left
      right: parent.right
    }
    running: true
  }

  Label {
    id: bchBalanceLabel
    anchors {
      top: updatingIndicator.bottom
      left: parent.left
      right: parent.right
			topMargin: units.gu(2)
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

	Button {
		id: receive
		anchors {
			top: fiatBalanceLabel.bottom
			topMargin: units.gu(2)
			left: parent.left
			leftMargin: units.gu(4)
		}
		text: i18n.tr('Receive')
		width: units.gu(16)
		onClicked: {
			pageStack.push(Qt.resolvedUrl("ReceivePage.qml"))
		}
		color: theme.palette.normal.base
	}

	Button {
		id: send
		anchors {
			top: fiatBalanceLabel.bottom
			topMargin: units.gu(2)
			right: parent.right
			rightMargin: units.gu(4)
		}
		text: i18n.tr('Send')
		width: units.gu(16)
		onClicked: {
			pageStack.push(Qt.resolvedUrl("SendPage.qml"))
		}
		color: theme.palette.normal.base
	}

  BottomEdge {
    id: bottomEdge
    contentUrl: Qt.resolvedUrl("ScanPage.qml")
    height: homePage.height

    hint {
      enabled: visible
      visible: bottomEdge.enabled
      text: i18n.tr("Scan")
      status: BottomEdgeHint.Active
    }

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

  Component.onCompleted: {
    python.call('backend.get_balance', [settings.userCurrencyCode], function(bal) {
      if (Qt.application.arguments[1].startsWith("bitcoincash")) {
        parseURI(Qt.application.arguments[1])
      }

      settings.bchBalance = bal[0]
      settings.fiatBalance = bal[1]
      updatingIndicator.running = false
    })
  }

  Connections {
    target: UriHandler

    onOpened: {
      if (uris.length > 0) {
        parseURI(uris[0])
      }
    }
  }

  function parseURI(uri) {
    var args = uri.split("?amount=")
		console.log("Passing to send" + args[0])
		pageStack.push(Qt.resolvedUrl("SendPage.qml"), {address: args[0], amount: args[1]})
  }
}
