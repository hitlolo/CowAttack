// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Item {
    id: spaceshipManager

    property int selectedScoutIndex: 0

    property int mothershipX: motherShip.x + motherShip.width / 2 - 28
    property int mothershipY: motherShip.y + motherShip.height / 2 + 100 - 26
    property alias motherMilk: motherShip.milk

    signal moveScout
    signal updateSpaceships
    signal recallShip
    property int destX
    property int destY

    Image {
        id: motherShadow
        source: "../../gfx/mothershadow.png"
        y: motherShip.y + 200
        x: motherShip.x
    }

    MouseArea {
        id: scoutControl
        x: 19
        y: grass.y
        width: grass.width - 38
        height: grass.height - 12
        property int ylimit : grass.y
        onClicked: {
            destX = mouseX - 14;
            destY = mouseY + y;
            if (destY < ylimit)
                destY = ylimit;
            moveScout();
        }
    }

    property int scoutCount: 3
    property int liveScoutCount: scoutCount
    onLiveScoutCountChanged: {
        if (liveScoutCount == 0)
            loseScreen.show();
    }

    // scouts
    Repeater {
        model: scoutCount
        delegate: Scout {
            scoutIndex: index
            x: Math.floor(40 + index * root.width*0.4)
            y: 200 + Math.random() * 200
            destX: x
            destY: y
        }
    }

    // mothership
    Mothership {
        id: motherShip
        y: 20
    }

    Timer {
        running: true
        repeat: true
        onTriggered: updateSpaceships();
        interval: heartBeat
    }
}
