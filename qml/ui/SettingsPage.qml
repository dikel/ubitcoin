import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

Page {
    id: settingsPage
    property int showDebug

    header: PageHeader {
    title: i18n.tr("Settings")
    flickable: flickable
    }

    Rectangle {
        height: units.gu(24)
    }
    Flickable {
        anchors.fill: parent
        contentHeight: settingsPage.childrenRect.height

        Column {
            anchors.fill: parent

            ListItem.SingleValue {
            }

            ListItem.SingleValue {
                text: i18n.tr("<b>General</b>")
            }

            ListItem.Standard {
                text: i18n.tr("Your currency?")
                enabled: true
                control: ComboBox {
                            id: currency
                            height: units.gu(5)
                            width: units.gu(20)
                            currentIndex: settings.currentIndex
                            textRole: "text"
                            model: ListModel {
                                id: currencyModel
                                ListElement { text: "BRL";  currency: "brl" }
                                ListElement { text: "CHF";  currency: "chf"}
                                ListElement { text: "EUR";  currency: "eur"}
                                ListElement { text: "GBP";  currency: "gbp" }
                                ListElement { text: "ISK";  currency: "isk"}
                                ListElement { text: "USD";  currency: "usd"}
                            }
                            onCurrentIndexChanged: {
                                settings.currentIndex = currency.currentIndex
                                settings.userCurrency = currencyModel.get(currentIndex).text
                                settings.userCurrencyCode = currencyModel.get(currentIndex).currency
                            }

                        }
            }
            ListItem.SingleValue {
                text: i18n.tr("<b>Donate (click on the address to copy)</b>")
            }
            ListItem.SingleValue {
                text: "bitcoincash:qr90ln6knmmzct8shekm27xj9xnlpes9uglhtcv5xn"
                onClicked: Clipboard.push("bitcoincash:qr90ln6knmmzct8shekm27xj9xnlpes9uglhtcv5xn")
            }
            ListItem.SingleValue {
                text: i18n.tr("<b>Information</b>")
            }
            ListItem.SingleValue {
                text: i18n.tr("Version")
                value: settings.version
            }
        }
    }

}
