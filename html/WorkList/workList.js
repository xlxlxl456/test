var dirs = null;
var root = null;

$(function () {
    root = this;
  
    // データ読み込み
    loadDirectory();

    // 選択ボタン
    $(".menu_button").click(function () {
        loadCompletionList();
    });
});

// call load directory to native
function loadDirectory() {
    console.log("loadDirectory");
    
    window.webkit.messageHandlers.loadDirectory.postMessage("");
}

// get direcotory[] from native
function setDirectoryData(dir) {
    console.log("setDirectoryData");
    
    dirs = dir;
    
    // show list
    addList(dir.length);
}

// リスト作成
function addList(num)
{
    console.log("addList");
    
    for(var i = 0; i < num; i++){

        var div_element = document.createElement("tr");
        div_element.innerHTML =
            '<td><div class="check cellcenter">\
                <a name="line' + i + '"></a><input type="radio" name="work" value="' + i + '"/></div>\
            </td>\
            <td>\
                <input class="workNum cellcenter" type="text" readonly="readonly" iLine="' + i + '" style="font-size:20px;"/>\
            </td>\
            <td>\
                <input class="workName" type="text" readonly="readonly" iLine="' + i + '" style="font-size:20px;"/>\
            </td>';
        var parent_object = document.getElementById("addListId");
        parent_object.appendChild(div_element);
    }
    setList();
}

// set workName into list
function setList() {
    console.log("setList: " + root);
    
    $(root).find(".workNum").each(function() {
                                    
        var iLine = $(this).attr("iLine");
        $(this).val(Number(iLine) + 1);
                                    
        var oparent = $(this).parent().parent();
        $(oparent).find(".workName").val(dirs[Number(iLine)]);
    });
}

// goto completionList
function loadCompletionList() {
    console.log("loadCompletionList");
    
    var r = $('input[name="work"]:checked').val();
    console.log(r);
    
    $(".workNum").each(function(){
        var iline = $(this).attr("iLine");
        if (r == iline){
            var str = $(this).val();
            console.log(str);
        }
    });
    console.log(dirs[r]);
    
    if (r != null) {        window.webkit.messageHandlers.loadCompletionList.postMessage(dirs[r]);
    }
}
