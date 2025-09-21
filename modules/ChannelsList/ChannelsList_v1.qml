import QtQuick 2.0

Item{
    id: r
    width: 100
    property int currentIndex: 0
    signal selectIndexChannel(int channelIndex)
    ListView{
        id: lv
        width: r.width
        height: r.height
        delegate: compItemList
        model: lm
        currentIndex: r.currentIndex
        ListModel{
            id: lm
            function add(urlIcon){
                return{
                    urlIcon: urlIcon
                }
            }
        }
    }
    Component{
        id: compItemList
        Rectangle{
            width: r.width
            height: width
            color: 'black'
            border.width: r.currentIndex===index?4:1
            border.color: r.currentIndex===index?'red':'white'
            MouseArea{
                anchors.fill: parent
                onClicked: r.selectIndexChannel(index)
            }
            Image{
                width: parent.width*0.8
                height: width
                source: urlIcon
                anchors.centerIn: parent
            }
            Rectangle{
                width: nc.contentWidth+app.fs*0.25
                height: app.fs*0.75
                color: 'black'
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    id: nc
                    text: '<b>'+parseInt(index+1)+'</b>'
                    font.pixelSize: app.fs*0.5
                    color: 'white'
                    anchors.centerIn: parent
                }
            }
        }
    }
    function updateList(a){
        lm.clear()
        for(var i=0;i<a.length;i++){
            lm.append(lm.add(a[i]))
        }
    }
}
