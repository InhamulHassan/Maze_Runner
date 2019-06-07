window.onload = function (e) {
    let mazeTable = document.getElementById("maze_table");
    let colNum = mazeTable.rows[0].cells.length;
    let rowNum = mazeTable.getElementsByTagName("tr").length;
    console.log('Rows: ' + rowNum + ' Columns: ' + colNum);
//    Mark the maze entry point
    let startPoint = mazeTable.rows[0].cells[0];
    startPoint.className = "start";
    console.log(startPoint);
    let endPoint = mazeTable.rows[colNum - 1].cells[rowNum - 1];
    endPoint.className = "end";
    console.log(endPoint);
};