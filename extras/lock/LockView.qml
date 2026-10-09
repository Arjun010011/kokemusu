import QtQuick
import QtQuick.Effects
import Quickshell
import qs.Commons
import qs.Ui

// Kokemusu lock screen: the wallpaper under one flat veil, a large serif time
// set low on the left like the corner of a print, and a solid password card.
// Grey borders in every state; moss shows only as one small dot. No gradients.
// Only the visuals differ from omarchy.lock: the public properties, signals and
// password handling are kept identical so Service.qml drives it unchanged.
Item {
  id: root

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  // ── Palette, read from the active theme so it follows colors.toml and shell.toml ──
  readonly property color ash: Color.background
  readonly property color paper: Color.lock.text
  readonly property color moss: Color.accent
  readonly property color dim: Util.alpha(Color.lock.text, 0.62)
  readonly property color faint: Util.alpha(Color.lock.text, 0.3)
  readonly property color rust: Color.lock.textError

  readonly property string serif: "Instrument Serif"
  readonly property string cjk: "Noto Serif CJK JP"
  readonly property string mono: Style.font.family
  readonly property real unit: Math.max(0.85, Math.min(width / 1600, height / 1000))

  readonly property bool errorState: failureMessage.length > 0
  readonly property bool typing: passwordInput.text.length > 0
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && !errorState

  readonly property string userName: Quickshell.env("USER") || ""
  property date now: new Date()

  readonly property string greeting: {
    var h = now.getHours()
    if (h < 5) return "still awake"
    if (h < 12) return "good morning"
    if (h < 17) return "good afternoon"
    if (h < 22) return "good evening"
    return "good night"
  }

  function fileUrl(path) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + backgroundVersion
  }

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  onFailedAttemptsChanged: if (failedAttempts > 0) shake.restart()
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  Timer {
    interval: 1000
    repeat: true
    running: root.visible
    triggeredOnStart: true
    onTriggered: root.now = new Date()
  }

  Rectangle {
    anchors.fill: parent
    color: root.ash

    // ── Backdrop: the wallpaper, lightly blurred, drifting very slowly ──
    Item {
      id: backdrop
      anchors.fill: parent
      layer.enabled: true   // blur once, then only transform the cached texture
      transformOrigin: Item.Center

      Image {
        id: wallpaper
        anchors.fill: parent
        visible: false
        source: root.loadBackground ? root.fileUrl(root.backgroundPath) : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        sourceSize.width: width
        sourceSize.height: height
      }

      MultiEffect {
        anchors.fill: wallpaper
        source: wallpaper
        autoPaddingEnabled: false
        visible: wallpaper.status === Image.Ready
        blurEnabled: true
        blur: 0.4
        blurMax: 48
        blurMultiplier: 1.0
        brightness: -0.1
        saturation: -0.18
        contrast: -0.06
      }

      SequentialAnimation on scale {
        running: root.loadBackground && root.visible
        loops: Animation.Infinite
        NumberAnimation { from: 1.02; to: 1.07; duration: 70000; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1.07; to: 1.02; duration: 70000; easing.type: Easing.InOutSine }
      }
    }

    // ── One flat veil of charcoal over the whole picture ──
    Rectangle {
      anchors.fill: parent
      color: Util.alpha(root.ash, 0.52)
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    // ── Time, set low on the left ──
    Column {
      id: timeBlock
      anchors.left: parent.left
      anchors.bottom: parent.bottom
      anchors.leftMargin: 112 * root.unit
      anchors.bottomMargin: 96 * root.unit
      spacing: 6 * root.unit

      opacity: root.loadBackground ? 1 : 0
      transform: Translate { y: root.loadBackground ? 0 : 16 * root.unit; Behavior on y { NumberAnimation { duration: 1200; easing.type: Easing.OutCubic } } }
      Behavior on opacity { NumberAnimation { duration: 1200; easing.type: Easing.OutCubic } }

      Text {
        text: Qt.formatDate(root.now, "dddd d MMMM").toUpperCase()
        color: root.dim
        font.family: root.mono
        font.pixelSize: 13 * root.unit
        font.letterSpacing: 4 * root.unit
      }

      Row {
        spacing: 14 * root.unit

        Text {
          id: clock
          text: Qt.formatTime(root.now, "h:mm AP").split(" ")[0]
          color: root.paper
          font.family: root.serif
          font.pixelSize: 196 * root.unit
          font.letterSpacing: -3 * root.unit
          layer.enabled: true
          layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.ash
            shadowOpacity: 0.45
            shadowBlur: 0.8
            shadowVerticalOffset: 3
          }
        }

        Text {
          anchors.baseline: clock.baseline
          text: Qt.formatTime(root.now, "AP").toLowerCase()
          color: root.dim
          font.family: root.serif
          font.italic: true
          font.pixelSize: 40 * root.unit
        }
      }

      Row {
        spacing: 12 * root.unit

        Rectangle {
          width: 7 * root.unit; height: width; radius: width / 2
          color: root.moss
          anchors.verticalCenter: parent.verticalCenter
        }
        Text {
          text: root.greeting + (root.userName ? ", " + root.userName : "")
          color: root.dim
          font.family: root.mono
          font.pixelSize: 14 * root.unit
          font.letterSpacing: 1.5 * root.unit
        }
      }
    }

    // ── Signature: 苔むす, small, top left ──
    Text {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.leftMargin: 112 * root.unit
      anchors.topMargin: 72 * root.unit
      opacity: root.loadBackground ? 0.7 : 0
      Behavior on opacity { NumberAnimation { duration: 1800; easing.type: Easing.OutCubic } }
      text: "苔むす"
      color: root.paper
      font.family: root.cjk
      font.weight: Font.Light
      font.pixelSize: 18 * root.unit
      font.letterSpacing: 8 * root.unit
    }

    // ── Password: a solid card with a grey border, bottom right ──
    Rectangle {
      id: inputField
      width: 340 * root.unit
      height: 56 * root.unit
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.rightMargin: 112 * root.unit
      anchors.bottomMargin: 112 * root.unit
      radius: 14 * root.unit
      color: Color.lock.background
      border.width: 1
      border.color: root.errorState ? Color.lock.borderError
        : (root.typing || root.authenticatingPassword || passwordInput.activeFocus ? Color.lock.borderActive : Color.lock.border)
      Behavior on border.color { ColorAnimation { duration: 260 } }

      opacity: root.loadBackground ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 1400; easing.type: Easing.OutCubic } }

      transform: Translate { id: shakeOffset }

      SequentialAnimation {
        id: shake
        NumberAnimation { target: shakeOffset; property: "x"; to: -10 * root.unit; duration: 60; easing.type: Easing.OutQuad }
        NumberAnimation { target: shakeOffset; property: "x"; to: 8 * root.unit; duration: 90; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeOffset; property: "x"; to: -5 * root.unit; duration: 90; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeOffset; property: "x"; to: 2 * root.unit; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 120; easing.type: Easing.OutQuad }
      }

      // Measures the masked password at full size so long passwords shrink to fit.
      TextMetrics {
        id: dotMetrics
        font.family: root.mono
        font.pixelSize: 18 * root.unit
        font.letterSpacing: 6 * root.unit
        text: "•".repeat(passwordInput.text.length)
      }

      TextInput {
        id: passwordInput
        anchors.fill: parent
        anchors.leftMargin: 20 * root.unit
        anchors.rightMargin: 20 * root.unit + (root.fingerprintConfigured ? 26 * root.unit : 0)
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignLeft
        activeFocusOnPress: true
        clip: true
        enabled: root.inputEnabled && !root.authenticatingPassword
        readOnly: root.authenticatingPassword
        echoMode: TextInput.Password
        passwordCharacter: "•"
        passwordMaskDelay: 0
        color: root.paper
        selectionColor: Color.lock.selection
        selectedTextColor: root.paper
        font.family: root.mono
        readonly property real fit: dotMetrics.advanceWidth > 0 ? Math.min(1, (width - 4) / dotMetrics.advanceWidth) : 1
        font.pixelSize: Math.max(1, Math.floor(18 * root.unit * fit))
        font.letterSpacing: 6 * root.unit * fit
        cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
        cursorDelegate: Rectangle {
          width: 1
          color: root.paper
          visible: passwordInput.cursorVisible
        }

        onTextChanged: {
          if (!root.syncingPasswordText) root.passwordTextEdited(text)
          if (text.length > 0) root.wakeRequested()
          if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
        }

        onAccepted: {
          var submitted = root.passwordText
          root.passwordTextEdited("")
          if (submitted.length > 0) root.submitPassword(submitted)
        }

        Keys.onPressed: function(event) {
          root.wakeRequested()
          if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
            root.passwordTextEdited("")
            event.accepted = true
          }
        }
      }

      Row {
        anchors.left: passwordInput.left
        anchors.verticalCenter: parent.verticalCenter
        visible: !root.typing
        spacing: 10 * root.unit

        // Checking: a small moss dot breathes while PAM works
        Rectangle {
          visible: root.authenticatingPassword
          width: 7 * root.unit; height: width; radius: width / 2
          color: root.moss
          anchors.verticalCenter: parent.verticalCenter
          SequentialAnimation on opacity {
            running: root.authenticatingPassword
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 0.25; duration: 600; easing.type: Easing.InOutSine }
            NumberAnimation { from: 0.25; to: 1; duration: 600; easing.type: Easing.InOutSine }
          }
        }

        Text {
          textFormat: Text.PlainText
          width: passwordInput.width - 20 * root.unit
          text: root.authenticatingPassword ? "checking" : (root.errorState ? root.failureMessage.toLowerCase() : "password")
          color: root.errorState ? root.rust : Color.lock.placeholder
          font.family: root.mono
          font.pixelSize: 13 * root.unit
          font.letterSpacing: 2 * root.unit
          elide: Text.ElideRight
          Behavior on color { ColorAnimation { duration: 300 } }
        }
      }

      Text {
        anchors.right: parent.right
        anchors.rightMargin: 18 * root.unit
        anchors.verticalCenter: parent.verticalCenter
        visible: !root.fingerprintConfigured
        text: "↵"
        color: root.typing ? root.paper : root.faint
        font.family: root.mono
        font.pixelSize: 16 * root.unit
        Behavior on color { ColorAnimation { duration: 200 } }
      }

      // Fingerprint hint, kept inside the card
      Text {
        id: fingerprintIcon
        objectName: "fingerprintIndicator"
        anchors.right: parent.right
        anchors.rightMargin: 16 * root.unit
        anchors.verticalCenter: parent.verticalCenter
        visible: root.fingerprintConfigured
        text: "󰈷"
        color: root.dim
        font.family: root.mono
        font.pixelSize: 18 * root.unit
      }
    }

    // ── Footer hint under the card ──
    Text {
      anchors.right: inputField.right
      anchors.top: inputField.bottom
      anchors.topMargin: 14 * root.unit
      opacity: root.loadBackground ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 1800; easing.type: Easing.OutCubic } }
      text: "esc clears"
      color: root.faint
      font.family: root.mono
      font.pixelSize: 11 * root.unit
      font.letterSpacing: 2 * root.unit
    }
  }
}
