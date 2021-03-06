/***************************************************************************/
/* This file is part of Attack of the Cows from outer Space.               */
/*                                                                         */
/*    Attack of the Cows from outer Space is free software: you can        */
/*    redistribute it and/or modify it under the terms of the GNU General  */
/*    Public License as published by the Free Software Foundation, either  */
/*    version 3 of the License, or (at your option) any later version.     */
/*                                                                         */
/*    Attack of the Cows from outer Space is distributed in the hope that  */
/*    it will be useful, but WITHOUT ANY WARRANTY; without even the        */
/*    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      */
/*    PURPOSE.  See the GNU General Public License for more details.       */
/*                                                                         */
/*    You should have received a copy of the GNU General Public License    */
/*    along with Attack of the Cows from outer Space.  If not,             */
/*    see <http://www.gnu.org/licenses/>.                                  */
/***************************************************************************/

import QtQuick 1.1
import SDLMixerWrapper 1.0

Item {
    id: mothership
    x: parent.width / 2 - width/2
    width: motherPic.width

    property int milk: 0
    property int milkMax: 2500

    onMilkChanged: if (milk > milkMax) {
                       milk = milkMax;
                       leave();
                   }

    SoundClip {
        id: explosionSound
        source: "sfx/explosion-big.ogg"
        volume: sfxVolume
    }

    SoundClip {
        id: leavingSound
        source: "sfx/beam-wowowfast.ogg"
        volume: sfxVolume
    }

    SoundClip {
        id: fallingSound
        source: "sfx/moo-massdeath.ogg"
        volume: sfxVolume
    }

    Image {
        id: motherPic
        y: incy
        property int incy
        source: ":/gfx/cowmothership3-256x138.png"

        SequentialAnimation {
            id: floatAnimation
            loops: Animation.Infinite
            running: true
            property int dur: 400
            PropertyAnimation {
                property: "incy"
                target: motherPic
                from: -4
                to: 4
                easing.type: Easing.InOutSine
                duration: floatAnimation.dur
            }
            PauseAnimation { duration: floatAnimation.dur }
            PropertyAnimation {
                property: "incy"
                target: motherPic
                from: 4
                to: -4
                easing.type: Easing.InOutSine
                duration: floatAnimation.dur
            }
            PauseAnimation { duration: floatAnimation.dur }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: spaceshipManager.recallShip()
        }

        Light { x: 26; y: 111 }
        Light { x: 80; y: 128 }
        Light { x: 128; y: 128 }
        Light { x: 166; y: 128 }
        Light { x: 225; y: 114 }
    }

    Rectangle {
        id: milkDisplay
        border.width: 0
        border.color: "black"
        color: "purple"
        visible: milk > 0
        width: milk / milkMax * mothership.width
        height: 8
        y : -8
        x : motherPic.x
        Rectangle {
            border.width: 1
            border.color: "black"
            color: "transparent"
            width: mothership.width
            height: parent.height
        }
    }

    function fall() {
        fallAnimation.start();
    }

    SequentialAnimation {
        id: fallAnimation
        ScriptAction {
            script: fallingSound.play();
        }
        SequentialAnimation {
            loops: 10
            PropertyAnimation {
                target: motherPic
                property: "y"
                from: 0
                to: -5
                duration: 50
                easing.type: Easing.InOutSine
            }
            PropertyAnimation {
                target: motherPic
                property: "y"
                from: -5
                to: 0
                duration: 50
                easing.type: Easing.InOutSine
            }
        }
        ParallelAnimation {
            RotationAnimation {
                target: motherPic
                property: "rotation"
                from: 0
                to: -90
                direction: RotationAnimation.Counterclockwise
                duration: 2000
                easing.type: Easing.InQuart
            }
            PropertyAnimation {
                target: motherPic
                property: "y"
                to: mothership.y + 200
                easing.type: Easing.InQuart
                duration: 2000
            }
            PropertyAnimation {
                target: motherPic
                property: "opacity"
                to: 0
                duration: 2000
                easing.type: Easing.InQuart
            }
            PropertyAnimation {
                target: motherShadow
                property: "opacity"
                to: 0
                duration: 2000
                easing.type: Easing.InQuart
            }
        }
        ScriptAction {
            script: {
                mothership.visible = false;
                explosionSound.play();
                loseScreen.show();
            }
        }
    }

    function leave()
    {
        spaceshipManager.recallAllShips();
//        leaveAnimation.start();
    }

    Connections {
        target: spaceshipManager
        onShipOnPlace: {
            var i, dockedCount = 0;
            for (i=0; i < cowPositions.count; i++) {
                if ((!cowPositions.get(i).scoutAlive) ||
                     (cowPositions.get(i).x - 24 == spaceshipManager.mothershipX &&
                        cowPositions.get(i).y - 16 == spaceshipManager.mothershipY))
                    dockedCount++;
            }

            if (dockedCount == 3)
                leaveAnimation.start();
        }
    }

    SequentialAnimation {
        id: leaveAnimation
        property int dur : 10000
        ScriptAction{
            script: leavingAlready = true;
        }
        PropertyAnimation {
            target: milkDisplay
            property: "opacity"
            to: 0
            duration: 1000
        }
        ParallelAnimation {
            PropertyAnimation {
                target: motherPic
                property: "x"
                from: 0
                to: root.width
                duration: leaveAnimation.dur
                easing.type: Easing.InQuart
            }
            PropertyAnimation {
                target: motherPic
                property: "y"
                to: -motherPic.height
                duration: leaveAnimation.dur
                easing.type: Easing.InQuart
            }
            PropertyAnimation {
                target: motherShadow
                property: "x"
                from: mothership.x
                to: root.width + mothership.x
                duration: leaveAnimation.dur
                easing.type: Easing.InQuart
            }
            PropertyAnimation {
                target: motherShadow
                property: "opacity"
                to: 0
                duration: leaveAnimation.dur
                easing.type: Easing.InQuart
            }
        }
        ScriptAction {
            script: {
                leavingAlready = false;
                winScreen.show();
            }
        }
    }

    property bool leavingAlready: false
    property int movingTime: 4119
    Timer {
        interval: heartBeat
        running: true
        repeat: true
        onTriggered: {
            if (leavingAlready) {
                movingTime -= interval;
                if (movingTime <= 0) {
                    leavingSound.play();
                    movingTime = 4119;
                }
            } else {
                movingTime = 0;
                leavingSound.stop();
            }
        }
    }
}
