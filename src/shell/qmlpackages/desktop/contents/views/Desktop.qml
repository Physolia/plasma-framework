/*
 *  Copyright 2012 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../activityswitcher"

Rectangle {
    id: root
    color: Qt.rgba(0, 0, 0, 0.2)
    width: 1024
    height: 768

    property Item containment

    function toggleWidgetExplorer(explorerObject) {
        console.log("Widget Explorer toggled");

        if (0&&sidePanel.visible) {
            explorerObject.close()
            sidePanel.visible = false;
        } else {
            explorerObject.parent = sidePanelStack
            explorerObject.anchors.fill = parent;
            sidePanel.visible = true;
            sidePanel.height = containment.availableScreenRegion(containment.screen)[0].height;
        }
    }

    function toggleActivityManager() {
        console.log("Activity manger toggled");

        if (sidePanel.visible) {
            sidePanelStack.source = '';
            sidePanel.visible = false;
        } else {
            sidePanelStack.source = Qt.resolvedUrl("../activityswitcher/ActivitySwitcher.qml");
            sidePanel.visible = true;
            sidePanel.height = containment.availableScreenRegion(containment.screen)[0].height;
        }
    }

    PlasmaCore.Dialog {
        id: sidePanel
        location: PlasmaCore.Types.LeftEdge
        mainItem: Loader {
            id: sidePanelStack
            width: 250
            height: 500
        }
    }

    onContainmentChanged: {
        print("New Containment: " + containment);
        print("Old Containment: " + internal.oldContainment);
        //containment.parent = root;
        containment.visible = true;
        
        internal.newContainment = containment;
        if (internal.oldContainment && internal.oldContainment != containment) {
            switchAnim.running = true;
        } else {
            internal.oldContainment = containment;
        }
    }

    //some properties that shouldn't be accessible from elsewhere
    QtObject {
        id: internal;

        property Item oldContainment;
        property Item newContainment;
    }

    SequentialAnimation {
        id: switchAnim
        ScriptAction {
            script: {
                containment.anchors.left = undefined;
                containment.anchors.top = undefined;
                containment.anchors.right = undefined;
                containment.anchors.bottom = undefined;

                internal.oldContainment.anchors.left = undefined;
                internal.oldContainment.anchors.top = undefined;
                internal.oldContainment.anchors.right = undefined;
                internal.oldContainment.anchors.bottom = undefined;

                internal.oldContainment.z = 0;
                internal.oldContainment.x = 0;
                containment.z = 1;
                containment.x = root.width;
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: internal.oldContainment
                properties: "x"
                to: -root.width
                duration: 400
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: internal.newContainment
                properties: "x"
                to: 0
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
        ScriptAction {
            script: {
                containment.anchors.left = root.left;
                containment.anchors.top = root.top;
                containment.anchors.right = root.right;
                containment.anchors.bottom = root.bottom;

                internal.oldContainment.visible = false;
                internal.oldContainment = containment;
            }
        }
    }

    
    Component.onCompleted: {
        //configure the view behavior
        desktop.stayBehind = true;
        desktop.fillScreen = true;
        print("View QML loaded")
    }

}
