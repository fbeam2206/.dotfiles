import QtQuick // Import the Types

Rectangle { // Rectangle is a type // Also Root
  id: page
  width: 320; height: 480
  color: "lightgray"

  Text { // Nested
    id: helloText
    text: "Hello world!"
    y: 30 
    anchors.horizontalCenter: page.horizontalCenter
    font.pointSize: 24; font.bold: true
  }

  Grid {
    id: colorPicker
    x: 4; anchors.bottom: page.bottom; anchors.bottomMargin: 4 
    rows: 2; columns: 3; spacing: 3 
    Cell { cellColor: "red";       onClicked: (cellColor) => helloText.color = cellColor }
    Cell { cellColor: "green";     onClicked: (cellColor) => helloText.color = cellColor }
    Cell { cellColor: "blue";      onClicked: (cellColor) => helloText.color = cellColor }
    Cell { cellColor: "yellow";    onClicked: (cellColor) => helloText.color = cellColor }
    Cell { cellColor: "steelblue"; onClicked: (cellColor) => helloText.color = cellColor }
    Cell { cellColor: "black";     onClicked: (cellColor) => helloText.color = cellColor }
  }

}
