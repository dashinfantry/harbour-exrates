import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/parser.js" as Parser

Page {
    id: root

    property string state: ""
    property bool modelDataError: false
    property string statusMessage: ""

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
/*            MenuItem { // Currently no options available
                text: qsTr("Options")
                onClicked: pageStack.push(Qt.resolvedUrl("OptionPage.qml"))
            }*/
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Select Base Currency")
                onClicked: pageStack.push(Qt.resolvedUrl("BasePage.qml"))
            }
            MenuItem {
                text: qsTr("Update Rates")
                onClicked: Parser.getBaseRates(rateModel.baseCurrency, true)
                visible: rateModel.count > 1
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height
        VerticalScrollDecorator {}

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: pageHead
                title: qsTr("ExRates")
            }

            Column {
                id: content

                x: Theme.horizontalPageMargin
                width: root.width - 2*x
                spacing: Theme.paddingMedium
                visible: rateModel.count > 1

                Text {
                    text: qsTr("Base Currency: ")+ "<br>" + rateModel.baseName
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    textFormat: Text.RichText
                }
                Label {
                    text: qsTr("Last update: ")+rateModel.rateDate
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeSmall 
                }

                TextField {
                    id: insert
                    width: parent.width
                    label: qsTr("Sum to convert")
                    placeholderText: qsTr("Enter sum")
                    inputMethodHints: Qt.ImhDigitsOnly
                    EnterKey.onClicked:  {
                        result.text = Math.round(text * rateModel.rate*100)/100
                    }
                }

                TextField {
                    id: result
                    width: parent.width
                    color: Theme.highlightColor
                    inputMethodHints: Qt.ImhDigitsOnly

                    placeholderText: qsTr("Result")
                    label: qsTr("Sum in ") + rateModel.cFullName

                    EnterKey.onClicked: {
                        insert.text = Math.round(text * 1/rateModel.rate*100)/100
                    }
                }

                Label {
                    id: listHeader
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    text: qsTr("Convert to: ") + rateModel.cFullName
                }
            }

            Text {
                id: into
                visible: rateModel.count == 0 || rateModel.hasError
                width: content.width
                x: Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
                text: rateModel.hasError ? rateModel.errorMsg:qsTr("Select a base currency from the drop down menu. This requires a internet connection. New rates can be downloaded once per day.")
            }

            SilicaListView {
                width: root.width
                height: root.height < 730 ? 600:root.height - content.height - pageHead.height - 2*column.spacing
                model: rateModel
                clip: true
                visible: rateModel.count > 0

                VerticalScrollDecorator {}

                BusyIndicator {
                    size: BusyIndicatorSize.Large
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: rateModel.count === 0
                }

                delegate: ListItem {
                    width: ListView.view.width
                    contentHeight: Theme.itemSizeSmall

                    Row {
                        x: Theme.horizontalPageMargin
                        spacing: Theme.paddingMedium
                        Image { source: "qrc:/icons/flags/"+ currency + ".png"}
                        Label { text: cName; width: Theme.fontSizeMedium*8 }
                        Label { text: currency }
                        Label { text: insert.text === "" ? rate:Math.round(insert.text * rate*100)/100 }
                    }
                    onClicked: {
                        rateModel.rate = rate
                        rateModel.cName = currency
                        rateModel.move(index, 0, 1)
                        Parser.rePosCurr(currency, 0)
                        result.text = Math.round(insert.text * rateModel.rate*100)/100
                    }

                    menu: Component {
                       id: contextMenu
                       ContextMenu {
                          MenuItem {
                              text: qsTr("Move up")
                              visible: index > 0
                              onClicked: {
                                  rateModel.move(index, index-1, 1)
                                  Parser.rePosCurr(currency, index-1)
                              }
                          }
                          MenuItem {
                              text: qsTr("Move down")
                              visible: index < rateModel.count -1
                              onClicked: {
                                  rateModel.move(index, index+1, 1)
                                  Parser.rePosCurr(currency, index+1)
                              }
                          }
/*                          MenuItem {
                              text: qsTr("Make base rate")
                              onClicked: {

                              }
                          }*/
                       }
                    }
                }
            }
        }
    }
}
