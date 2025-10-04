import QtQuick 2.7
import QtQuick.Controls 2.12
import QtQuick.Window 2.0
import QtMultimedia 5.12
import Qt.labs.settings 1.0
import unik.UnikQProcess 1.0
import UniKey 1.0

import ChannelsList 1.0

/*
Requerimientos para Ubuntu 20.04
sudo apt install gstreamer1.0-plugins-base
sudo apt install gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad

OBTENER CANALES
curl https://iptv-org.github.io/iptv/languages/spa.m3u > canales-espanol.m3u
*/

ApplicationWindow{
    id: app
    visible: true
    visibility: 'Maximized'
    title: 'CuteTV'
    color: 'black'

    property int fs:  screen.width*0.02
    property var currentJson//: ({})
    UniKey{id: u}
    Settings{
        id: apps
        fileName: u.getPath(4)+'/'+app.title+'.cfg'
        property real volume: 0.0
        property int currentIndexCbCountries: 0
        property string uUrl: ''
        property string uChannelNom: ''
        property string uImgIconUrl: ''
    }
    UnikQProcess{
        id: uqp
        onFinished:{
            ta.text+='\n'+logData
            let url=logData.replace(/\n/g, '').replace(/ /g, '')
            let i=app.aUrls.indexOf(url)
            ta.text+='Index: '+i
            //if(i>=0)app.currentIndexChannel=i
            if(url.indexOf('https://')>0)miVlc.source=url
        }
    }

    Item{
        id: xApp
        anchors.fill: parent

        Row{
            spacing: app.fs
            anchors.centerIn: parent
            Rectangle{
                id: xLatIzq
                width: app.fs*6
                height: xApp.height
                color: 'transparent'
                border.width: 1
                border.color: 'white'
                Column{
                    anchors.centerIn: parent
                    ComboBox{
                        id: cbCountries
                        width: xLatIzq.width
                        //height: app.fs*1.2
                        font.pixelSize: app.fs*0.5
                        //model: ['aaa', 'dsfasf']
                        model: ['Argentina', 'Perú']
                        property var aCountriesUrls: ['']

                        currentIndex: apps.currentIndexCbCountries
                        onCurrentIndexChanged:  {
                            currentIndexCbCountries=currentIndex
                            getIpTvUrls(aCountriesUrls[currentIndex])
                        }
                        //onCurrentTextChanged: updateCat(currentText)
                    }
                    ComboBox{
                        id: cbCats
                        width: xLatIzq.width
                        //height: app.fs*1.2
                        font.pixelSize: app.fs*0.5
                        //model: ['aaa', 'dsfasf']
                        model: ['Todo','Deportes', 'Noticias', 'Películas', 'Comedia', 'Series', 'Kids', 'Animación', 'Educación', 'Música', 'Familia', 'Cultura', 'Entretenimiento', 'Viajes', 'Religión', 'Estilo de Vida', 'Publico', 'Fuera de Casa', 'Legislativo', 'Cocina']
                        property var aCatNoms: ['Todo','Sports', 'News', 'Movies', 'Comedy', 'Series', 'Kids', 'Animation', 'Education', 'Music', 'Family', 'Culture', 'Entertainment', 'Travel', 'Religious', 'Lifestyle', 'Public', 'Outdoor', 'Legislative', 'Cooking']

                        currentIndex: 0
                        onCurrentIndexChanged:  updateCat(aCatNoms[currentIndex])
                        //onCurrentTextChanged: updateCat(currentText)
                    }
                    Rectangle{
                        id: xTiSearch
                        width: xLatIzq.width
                        height: app.fs*1.5
                        color: 'black'
                        border.width: 2
                        border.color: 'white'
                        clip: true
                        TextInput{
                            id: tiSearch
                            width: parent.width-app.fs*0.1
                            height: parent.height-app.fs*0.1
                            font.pixelSize: app.fs
                            color: 'white'
                            anchors.centerIn: parent
                            Keys.onReturnPressed: {
                                let cmd='sh  '+u.currentFolderPath()+'/search.sh '+u.currentFolderPath()+'/canales-espanol.m3u "'+tiSearch.text+'"'
                                uqp.run(cmd)
                            }
                        }
                    }
                    ChannelsList{
                        id: cl
                        width: xLatIzq.width
                        height: xApp.height-xTiSearch.height-cbCats.height-cbCountries.height
                        currentIndex: app.currentIndexChannel
                        clip: true
                        onSelectIndexChannel:{
                            app.currentIndexChannel=channelIndex
                        }
                    }
                }
            }
            Column{
                anchors.verticalCenter: parent.verticalCenter
                Rectangle{
                    id: xCab
                    width: xVideoMin.width
                    height: app.fs*3
                    color: '#333'
                    Row{
                        spacing: app.fs*0.5
                        Rectangle{
                            id: xIcon
                            width: height
                            height: xCab.height
                            color: 'transparent'
                            Image{
                                id: iconImg
                                source: apps.uImgIconUrl
                                anchors.fill: parent
                            }
                        }
                        Rectangle{
                            width: xCab.width-xIcon.width-parent.spacing
                            height: app.fs*1.2
                            color:  '#333'
                            anchors.verticalCenter: parent.verticalCenter
                            visible: txtChannelNom.text.indexOf('Desconocido')<0
                            Text{
                                id: txtChannelNom
                                text: ' Canal: '+apps.uChannelNom
                                font.pixelSize: app.fs*0.5
                                color: 'white'
                                anchors.centerIn: parent
                            }
                        }
                    }
                }
                Rectangle{
                    id: xVideoMin
                    width: app.fs*20
                    height: miVlc.height//width
                    color: 'transparent'
                    border.width: 2
                    border.color: 'white'
                    Video{
                        id: miVlc
                        width: parent.width
                        height: width/16*9
                        autoLoad: true
                        autoPlay: true
                        volume: apps.volume
                        //fillMode: VideoOutput.PreserveAspectCrop
                        fillMode: VideoOutput.PreserveAspectFit
                        anchors.centerIn: parent
                        source: apps.uUrl
                        onSourceChanged: {
                           apps.uUrl=miVlc.source
                           if(app.currentJson && app.currentJson.names){
                                apps.uChannelNom=app.currentJson.names[app.currentJson.urls.indexOf(apps.uUrl)]
                           }
                           if(app.currentJson && app.currentJson.pings){
                                apps.uImgIconUrl=app.currentJson.pings[app.currentJson.urls.indexOf(apps.uUrl)]
                           }
                        }
                        onStatusChanged: {
                            loading.text='Cargando...'
                            // Verifica el nuevo estado del reproductor
                            if (status === Video.Loading) {
                                console.log("El video está cargando...");
                                //loading.visible=true
                            } else if (status === Video.Ready) {
                                console.log("El video está listo para reproducirse.");
                                //loading.visible=false
                            } else if (status === Video.Playing) {
                                console.log("El video se está reproduciendo.");
                                apps.uUrl=miVlc.source
                                //loading.visible=false
                            } else if (status === Video.Error) {
                                console.error("Ocurrió un error al reproducir el video.");
                                xLog.visible=true
                                ta.text+='Error al cargar la url '+app.aUrls[app.currentIndexChannel]
                                //loading.visible=true
                                loading.text='Falló!'
                            }
                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        onDoubleClicked: {
                            if(miVlc.parent===xVideoMax){
                                miVlc.parent=xVideoMin
                            }else{
                                miVlc.parent=xVideoMax
                            }
                        }
                    }
                    Text{
                        id: loading
                        text: 'Cargando'
                        font.pixelSize: app.fs
                        color: 'white'
                        anchors.centerIn: parent
                        z:parent.z-1
                    }
                }
                Rectangle{
                    width: xVideoMin.width
                    height: app.fs
                    color: '#333'
                    Text{
                        id: txtUrl
                        text: 'Url: '+apps.uUrl
                        font.pixelSize: app.fs*0.5
                        color: 'white'
                        anchors.centerIn: parent
                        onTextChanged: font.pixelSize=app.fs*0.5
                        Timer{
                            running: parent.contentWidth>parent.parent.width-app.fs*0.25
                            repeat: true
                            interval: 100
                            onTriggered: parent.font.pixelSize-=2
                        }
                    }
                    Rectangle{
                        width: app.fs*0.5
                        height: width
                        radius: width*0.5
                        anchors.verticalCenter: parent.verticalCenter
                        color: miVlc.status===Video.Error?'red':
                                                           (
                                                            miVlc.status===Video.Loading?'gray':'green'
                                                           )
                        MouseArea{
                            anchors.fill: parent
                            onClicked:{
                                let nUrl=miVlc.source
                                let d = new Date(Date.now())
                                nUrl+='?r='+d.getTime()
                                miVlc.source=nUrl
                            }
                        }
                    }
                }
            }

            Rectangle{
                id: xLog
                width: xApp.width-cl.width-xVideoMin.width-parent.spacing*2
                height: xApp.height
                color: 'black'
                border.width: 1
                border.color: 'white'
                //visible: false
                Flickable{
                    id: flk
                    anchors.fill: parent
                    contentWidth: width
                    contentHeight: ta.contentHeight
                    Text{
                        id: ta
                        width: parent.width
                        height: contentHeight+100
                        color: 'white'
                        font.pixelSize: 20
                        wrapMode: TextArea.WrapAnywhere
                        onTextChanged: {
                            flk.contentY=flk.contentHeight-flk.height
                        }
                    }
                }
            }
        }
        Item{
            id: xVideoMax
            anchors.fill: parent
        }
    }

    property int currentIndexChannel: 0
    property var aUrls: []
    property var aUrlsIcons: []
    onCurrentIndexChannelChanged: {
        miVlc.source=aUrls[app.currentIndexChannel]
        clipboard.setText(miVlc.source)
    }
    Component.onCompleted: {
        let std=''
        let languagesUrls=[]
        languagesUrls.push('https://iptv-org.github.io/iptv/languages/spa.m3u')

        //getIpTvUrls(languagesUrls[0])

        let aCountriesNoms=[]
        let aUrlsCountries=[]
        //Canales Argentinos
        aCountriesNoms.push('Argentina')
        aUrlsCountries.push('https://iptv-org.github.io/iptv/countries/ar.m3u')
        //Canales Peruanos
        aCountriesNoms.push('Perú')
        aUrlsCountries.push('https://iptv-org.github.io/iptv/countries/pe.m3u')

        cbCountries.model=aCountriesNoms
        cbCountries.aCountriesUrls=aUrlsCountries

        getIpTvUrls(aUrlsCountries[apps.currentIndexCbCountries])

        //updateCat('Todo')
    }

    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
    Shortcut{
        sequence: 'Left'
        onActivated: {
            if(apps.volume>0.0){
               apps.volume-=0.1
            }
        }
    }
    Shortcut{
        sequence: 'Right'
        onActivated: {
            if(apps.volume<1.0){
               apps.volume+=0.1
            }
        }
    }
    Shortcut{
        sequence: 'Down'
        onActivated: {
            if(app.currentIndexChannel<app.aUrls.length){
                app.currentIndexChannel++
            }else{
                app.currentIndexChannel=0
            }
        }
    }
    Shortcut{
        sequence: 'Up'
        onActivated: {
            if(app.currentIndexChannel>0){
                app.currentIndexChannel--
            }else{
                app.currentIndexChannel=app.aUrls.length-1
            }
        }
    }

    function getIpTvUrls(url){
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("Success! Data received:", xhr.responseText);
                    //let fd=u.getFile('./canales-espanol.m3u')
                    //ta.text=xhr.responseText
                    app.currentJson=parsearM3UFile(xhr.responseText)
                    updateCat('Todo')
                } else {
                    console.log("Error! Status code:", xhr.status);
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }
    function parsearM3UFile(fileData) {
      if (typeof fileData !== 'string' || !fileData.startsWith('#EXTM3U')) {
        ta.text='El archivo M3U no tiene un formato válido.'
        return null;
      }

      const urls = [];
      const pings = [];
      const groups = [];
      const names = [];

      // Divide el contenido en líneas
      const lines = fileData.split('\n');

      // Itera sobre las líneas para extraer la información
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];

        // Busca las líneas que contienen la metadata del canal
        if (line.startsWith('#EXTINF')) {
          // Extrae la URL del canal de la siguiente línea
          const url = lines[i + 1];
          if (url && url.trim().startsWith('http')) {
            urls.push(url.trim());

            // Usa expresiones regulares para extraer los otros datos
            const groupMatch = line.match(/group-title="([^"]*)"/);
            //const nameMatch = line.match(/tvg-name="([^"]*)"/);
              const nameMatch = line.match(/tvg-id="([^"]*)"/);
            const pingMatch = line.match(/tvg-logo="([^"]*)"/);

            // Almacena los datos extraídos o una cadena vacía si no se encuentran
            groups.push(groupMatch ? groupMatch[1] : 'Desconocido');
            names.push(nameMatch ? nameMatch[1] : 'Desconocido');
            pings.push(pingMatch ? pingMatch[1] : 'Sin Logo');

            // Incrementa el contador para saltar la línea de la URL en la siguiente iteración
            i++;
          }
        }
      }

      return {
        urls,
        pings,
        groups,
        names
      };
    }
    function updateCat(cat){
        if(!app.currentJson){
            ta.text+='No se cargaron las urls correctamente.'
            return
        }
        let aUrls=[]
        let aImgs=[]
        for(var i=0;i<app.currentJson.urls.length;i++){
            //if(app.currentJson.groups[i]===cat || cat === 'Todo'){
            if(app.currentJson.groups[i].indexOf(cat)>=0 || cat === 'Todo'){
                aUrls.push(app.currentJson.urls[i])
                aImgs.push(app.currentJson.pings[i])
            }
//            if(app.currentJson.groups[i].indexOf('C')){
//                ta.text+=''+app.currentJson.groups[i]
//            }
        }
        app.aUrls=aUrls
        app.aUrlsIcons=aImgs
        cl.updateList(app.aUrlsIcons)
        ta.text+='Se encontraron '+app.aUrls.length+' de '+cat+'.'

    }
}
