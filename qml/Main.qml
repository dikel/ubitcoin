import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

MainView {
  id: root
  objectName: 'mainView'
  applicationName: 'ubitcoin.ixerious'
  automaticOrientation: true

  width: units.gu(45)
  height: units.gu(75)

  Settings {
		id: settings
		property string userCurrency: "USD"
		property string userCurrencyCode: "usd"
		property int currentIndex: 5
		property string bchBalance: "0.0"
		property string fiatBalance: "0.0"
		property string version: "0.2.1"
	}

  PageStack {
    id: mainPageStack
  }
  Component.onCompleted: {
	   mainPageStack.push(Qt.resolvedUrl("ui/HomePage.qml"))
  }

  Python {
    id: python

    Component.onCompleted: {
      addImportPath(Qt.resolvedUrl('../'))

      importModule('backend', function() {
        console.log('Debug: python loaded')
      });
    }

    onError: {
      console.log('python error: ' + traceback)
    }
  }
}
