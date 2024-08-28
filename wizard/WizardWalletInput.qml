// Copyright (c) 2014-2024, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.9
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import FontAwesome 1.0

import "../js/Wizard.js" as Wizard
import "../components"
import "../components" as MoneroComponents

GridLayout {
    id: grid
    Layout.fillWidth: true
    property alias walletName: walletName
    property alias walletLocation: walletLocation
    property alias browseButton: browseButton
    property alias errorMessageWalletName: errorMessageWalletName
    property alias errorMessageWalletLocation: errorMessageWalletLocation
    property bool rowLayout: true
    property var walletNameKeyNavigationBackTab: browseButton
    property var browseButtonKeyNavigationTab: walletName

    columnSpacing: rowLayout ? 20 : 0
    rowSpacing: rowLayout ? 0 : 20
    columns: rowLayout ? 2 : 1

    function verify() {
        return (
            walletName.text !== '' && walletLocation.text !== '' &&
            walletName.verify() && walletLocation.verify()
        );
    }

    function reset() {
        walletLocation.text = appWindow.accountsDir;
        walletName.text = Wizard.unusedWalletName(appWindow.accountsDir, defaultAccountName, walletManager);
    }

    ColumnLayout {
        MoneroComponents.LineEdit {
            id: walletName
            Layout.preferredWidth: grid.width/5

            function verifyWithMessage() {
                if (walletName.text === "") {
                    return qsTr("Wallet name is empty") + translationManager.emptyString;
                }
                if (/[\\\/]/.test(walletName.text)) {
                    return qsTr("Wallet name is invalid") + translationManager.emptyString;
                }
                if (
                    walletLocation.text !== "" &&
                    Wizard.walletPathExists(appWindow.accountsDir, walletLocation.text, walletName.text, isIOS, walletManager)
                ) {
                    return qsTr("Wallet already exists") + translationManager.emptyString;
                }

                return "";
            }

            function verify() {
                return !verifyWithMessage();
            }

            labelText: qsTr("Wallet name") + translationManager.emptyString
            labelFontSize: 14
            fontSize: 16
            placeholderFontSize: 16
            placeholderText: ""
            errorWhenEmpty: true
            text: defaultAccountName

            Accessible.role: Accessible.EditableText
            Accessible.name: labelText + text
            KeyNavigation.up: walletNameKeyNavigationBackTab
            KeyNavigation.backtab: walletNameKeyNavigationBackTab
            KeyNavigation.down: errorMessageWalletName.text !== "" ? errorMessageWalletName : (appWindow.walletMode >= 2 ? walletLocation : browseButtonKeyNavigationTab)
            KeyNavigation.tab: errorMessageWalletName.text !== "" ? errorMessageWalletName : (appWindow.walletMode >= 2 ? walletLocation : browseButtonKeyNavigationTab)
        }

        RowLayout {
            Layout.preferredWidth: grid.width/5

            MoneroComponents.TextPlain {
                visible: !walletName.verify()
                font.family: FontAwesome.fontFamilySolid
                font.styleName: "Solid"
                font.pixelSize: 15
                text: FontAwesome.exclamationCircle
                color: "#FF0000"
                themeTransition: false
            }

            MoneroComponents.TextPlain {
                id: errorMessageWalletName
                text: walletName.verifyWithMessage()
                textFormat: Text.PlainText
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: "#FF0000"
                themeTransition: false
                Accessible.role: Accessible.StaticText
                Accessible.name: text
                KeyNavigation.up: walletName
                KeyNavigation.backtab: walletName
                KeyNavigation.down: walletLocation
                KeyNavigation.tab: walletLocation
            }
        }
    }

    ColumnLayout {
        visible: appWindow.walletMode >= 2

        MoneroComponents.LineEdit {
            id: walletLocation
            Layout.preferredWidth: grid.width/3

            function verifyWithMessage() {
                if (walletLocation.text === "") {
                    return qsTr("Wallet location is empty") + translationManager.emptyString;
                }

                return "";
            }

            function verify() {
                return !verifyWithMessage();
            }

            labelText: qsTr("Wallet location") + translationManager.emptyString
            labelFontSize: 14
            fontSize: 16
            placeholderText: ""
            placeholderFontSize: 16
            errorWhenEmpty: true
            text: appWindow.accountsDir + "/"
            Accessible.role: Accessible.EditableText
            Accessible.name: labelText + text
            KeyNavigation.up: errorMessageWalletName.text !== "" ? errorMessageWalletName : walletName
            KeyNavigation.backtab: errorMessageWalletName.text !== "" ? errorMessageWalletName : walletName
            KeyNavigation.down: browseButton
            KeyNavigation.tab: browseButton

            MoneroComponents.InlineButton {
                id: browseButton
                fontFamily: FontAwesome.fontFamilySolid
                fontStyleName: "Solid"
                fontPixelSize: 18
                text: FontAwesome.folderOpen
                tooltip: qsTr("Browse") + translationManager.emptyString
                tooltipLeft: true
                onClicked: {
                    fileWalletDialog.folder = walletManager.localPathToUrl(walletLocation.text)
                    fileWalletDialog.open()
                    walletLocation.focus = true
                }
                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Browse") + translationManager.emptyString
                KeyNavigation.up: walletLocation
                KeyNavigation.backtab: walletLocation
                KeyNavigation.down: errorMessageWalletLocation.text !== "" ? errorMessageWalletLocation : browseButtonKeyNavigationTab
                KeyNavigation.tab: errorMessageWalletLocation.text !== "" ? errorMessageWalletLocation : browseButtonKeyNavigationTab
            }
        }

        RowLayout {
            Layout.preferredWidth: grid.width/3

            MoneroComponents.TextPlain {
                visible: !walletLocation.verify()
                font.family: FontAwesome.fontFamilySolid
                font.styleName: "Solid"
                font.pixelSize: 15
                text: FontAwesome.exclamationCircle
                color: "#FF0000"
                themeTransition: false
            }

            MoneroComponents.TextPlain {
                id: errorMessageWalletLocation
                text: walletLocation.verifyWithMessage()
                textFormat: Text.PlainText
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: "#FF0000"
                themeTransition: false
                Accessible.role: Accessible.StaticText
                Accessible.name: text
                KeyNavigation.up: browseButton
                KeyNavigation.backtab: browseButton
                KeyNavigation.down: browseButtonKeyNavigationTab
                KeyNavigation.tab: browseButtonKeyNavigationTab
            }
        }
    }

    FileDialog {
        id: fileWalletDialog
        selectMultiple: false
        selectFolder: true
        title: qsTr("Please choose a directory")  + translationManager.emptyString
        onAccepted: {
            walletLocation.text = walletManager.urlToLocalPath(fileWalletDialog.folder);
            fileWalletDialog.visible = false;
        }
        onRejected: {
            fileWalletDialog.visible = false;
        }
    }
}
