import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import QtMultimedia 5.8

import QZXing 2.3

Page {
	id: scanPage

  header: PageHeader {
    id: header
    title: i18n.tr('Scan')
  }

  Camera {
    id: camera

    focus.focusMode: Camera.FocusMacro + Camera.FocusContinuous
    focus.focusPointMode: Camera.FocusPointCenter

		exposure.exposureMode: Camera.ExposureBarcode
  }

	Connections {
	    target: bottomEdge
	    onCommitCompleted: {
				camera.start()
			}
			onCollapseCompleted: {
				camera.stop()
			}
	}

	VideoOutput {
		source: camera
		anchors.fill: parent
		focus: visible
		autoOrientation: true
		fillMode: Image.PreserveAspectCrop

		MouseArea {
      anchors.fill: parent
      onClicked: {
        camera.focus.customFocusPoint = Qt.point(mouse.x / width,
                                                 mouse.y / height)
        camera.focus.focusMode = CameraFocus.FocusMacro
        camera.focus.focusPointMode = CameraFocus.FocusPointCustom
      }
    }
	}

}
