var completionModel = null;
var poleNum = -1;
var root = null;
var mode = 0;
var sDialog = null;
var files = null;
var optionLen = 0;

$(function () {
    root = this;
    
    // init dialog
    initDialog();
    
    // load current completionModel
    loadCurrentData();
    
    // get poleNum
    window.webkit.messageHandlers.loadPoleNum.postMessage("");
    
    // saveボタン
    $(".saveButton").click(function () {
        console.log("saveButton");
        
        // チェックボックス、写真の日付を取得
        getCheck();
        getDate();
        
        // save json
        utilSaveJSON();
    });
    
    // 10件表示ボタン
    $(".listButton").click(function () {
        console.log("listButton");

        // チェックボックス、写真の日付を取得
        getCheck();
        getDate();

        // save json
        utilSaveJSON();
        
        // save TimeStamp
        utilSaveTimeStamp(poleNum, 0);
        
        // set pole number -1
        window.webkit.messageHandlers.setPoleNum.postMessage("-1");
        
        // goto CompletionList.html
        window.webkit.messageHandlers.loadHtml.postMessage("completionList");
    });
    
    // reloadボタン
    $(".reload").click(function () {
        location.reload();
    });
    
    // memoボタン
    $(".memo").click(function () {
        window.webkit.messageHandlers.addNote.postMessage("");
    });
    
    // 1. 開閉器が無のときは操作紐を否にする
    $(".non-switch").change(function () {
        if ($(this).val() == "無") {
            $(".non-existence").val("否");
        }
    });
    
    // 2. 共架予定位置のチェックはどちらか一方がチェック → 重複を許可
//    $(".planCheck1").click(function () {
//        if ($(this).prop('checked')) {
//            $(".planCheck2").prop('checked', false);
//        }
//    });
//    $(".planCheck2").click(function () {
//        if ($(this).prop('checked')) {
//            $(".planCheck1").prop('checked', false);
//        }
//    });
    
    // 工事前写真
    $(".photoBefore").click(function () {
        if (mode == 0) {
            gotoCamera(0);
        }
    });

    // 工事後写真
    $(".photoAfter").click(function () {
        if (mode == 1) {
            gotoCamera(1);
        }
    });
    
    // select image
    $(".imgSelect").click(function() {
        // check mode
        var val = $(this).attr("mode");
        // if mode match
        if (mode == val) {
            showImageDialog(val);
        }
    });
    
    // next focus on enter
    $(function() {
        $('input').on("keydown", function(e) {
            var n = $("input").length;
            if (e.which == 13) {
                e.preventDefault();
                var Index = $('input').index(this);
                var nextIndex = $('input').index(this) + 1;
                if (nextIndex < n) {
                    $('input')[nextIndex].focus();   // 次の要素へフォーカスを移動
                } else {
                    $('input')[Index].blur();        // 最後の要素ではフォーカスを外す
                }
            }
        });
    });
});

// init image select dialog
function initDialog() {
    var btOK = document.getElementById('btOK');
    var sImtes = document.getElementById('selectItems');
    
    var dialog = document.querySelector('dialog');
    dialogPolyfill.registerDialog(dialog);
    sDialog = document.getElementById('selectDialog');
    
    var outputBox = document.getElementsByTagName('output')[0];
    
    btOK.addEventListener('click', function() {
        
        // check option length
        var selectCount = $('#selectItems').children('option').length;
        
        // if option lenght == 1, not reload
        if (selectCount == 1)
            return;
        
        if (mode == 0) {
        
            // if same file, not reload
            var sName = $("#selectItems").val();
            if (sName == completionModel.JointUseModels[
            poleNum - 1].BeforeModelItems.PhotoName) {
                return;
            }
            else {
                var photos = completionModel.JointUseModels[poleNum - 1].BeforeModelItems.Photos;
                
                // photoNum == 1, not reload
                if (photos.length == 1) {
                    return;
                }
                
                // search in Photos
                photos.forEach (function (photo) {
                    // if hit name, set Photo and load image file
                    if (photo.PhotoName == sName){
                        // set Photo
                        completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoDate = photo.PhotoDate
                        completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoNumber = photo.PhotoNumber
                        completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoSrc = photo.PhotoSrc
                        completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoName = photo.PhotoName
                        // チェックボックス、写真の日付を取得、保存
                        getCheck();
                        getDate();
                        utilSaveJSON();
                        //load image file
                        loadImageSrc();
                    }
                });
            }
        }
        else if (mode == 1) {
        
            // if same file, not reload
            var sName = $("#selectItems").val();
            if (sName == completionModel.JointUseModels[
            poleNum - 1].AfterModelItems.PhotoName) {
                return;
            }
            else {
                var photos = completionModel.JointUseModels[poleNum - 1].AfterModelItems.Photos;
                
                // photoNum == 1, not reload
                if (photos.length == 1) {
                    return;
                }
                
                // search in Photos
                photos.forEach (function (photo) {
                    // if hit name, set Photo and load image file
                    if (photo.PhotoName == sName){
                        // set Photo
                        completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoDate = photo.PhotoDate
                        completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoNumber = photo.PhotoNumber
                        completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoSrc = photo.PhotoSrc
                        completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoName = photo.PhotoName
                        // チェックボックス、写真の日付を取得、保存
                        getCheck();
                        getDate();
                        utilSaveJSON();
                        //load image file
                        loadImageSrc();
                    }
                });
            }
        }
    });
}

// call load current completionModel to native
function loadCurrentData() {
    console.log("loadCurrentData");
    window.webkit.messageHandlers.loadCurrentData.postMessage("");
}

// get current completionModel from native
function setCurrentData(json) {
    console.log("setCurrentData");
    completionModel = json;
}

// get current polenum from native
function setPoleNum(num){
    poleNum = num;
    console.log("getPoleNum: " + poleNum);
    
    // show table
    setTable(poleNum);
    
    // show number
    $(".show_num").text("No. " + poleNum);
}

function setTable(poleNum) {
    console.log("setTable: " + root);
    console.log("poleNum: " + poleNum);
    
    mode = completionModel.WorkState;
    
    $(root).find(".joint").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        $(this).val(completionModel.JointUseModels[line - 1][name]);
        
        // 電柱番号の編集を許可
//        if (name == "PoleNumber"){
//            $(this).attr('readonly', true);
//        }
        
        // 工事後のときは操作NG
        var tag = $(this).prop("tagName");
        if (mode == 1) {
            if (tag == "INPUT") {
                $(this).prop('readonly', true);
            }
            else if (tag == "SELECT") {
                $(this).prop('disabled', true);
            }
        }
    });
    
    $(root).find(".before").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        if (name == "Single" || name == "Bundling") {
            // checkbox
            var check = String(completionModel.JointUseModels[line - 1].BeforeModelItems[name]);
            console.log(name + ": " + check);
            
            if (check ==  "true") {
                $(this).prop('checked', true);
            }
            else {
                $(this).prop('checked', false);
            }
        }
        else {
            // else
            $(this).val(completionModel.JointUseModels[line - 1].BeforeModelItems[name]);
        }
        
        // 工事後のときは操作NG
        var tag = $(this).prop("tagName");
        if (mode == 1) {
            if (tag == "INPUT") {
                $(this).prop('readonly', true);
            }
            else if (tag == "SELECT") {
                $(this).prop('disabled', true);
            }
        }
    });
    
    $(root).find(".beforePhoto").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.JointUseModels[line - 1].BeforeModelItems["PhotoDate"];
        var strs = dateStr.split('/');
        
        if (strs.length == 3 && strs[0] != "") {
            if (num == 1) {
                $(this).val(String(Number(strs[0]) - 2018));
                if (String(Number(strs[0]) - 2018) == "0") {
                    $(this).val("");
                }
            }
            if (num == 2) {
                $(this).val(strs[1]);
            }
            if (num == 3) {
                $(this).val(strs[2]);
            }
        }
        
        // 工事後のときは操作NG
        var tag = $(this).prop("tagName");
        if (mode == 1) {
            if (tag == "INPUT") {
                $(this).prop('readonly', true);
            }
            else if (tag == "SELECT") {
                $(this).prop('disabled', true);
            }
        }
    });
    
    $(root).find(".afterPhoto").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.JointUseModels[line - 1].AfterModelItems["PhotoDate"];
        var strs = dateStr.split('/');
        
        if (strs.length == 3 && strs[0] != "") {
            if (num == 1) {
                $(this).val(String(Number(strs[0]) - 2018));
                if (String(Number(strs[0]) - 2018) == "0") {
                    $(this).val("");
                }
            }
            if (num == 2) {
                $(this).val(strs[1]);
            }
            if (num == 3) {
                $(this).val(strs[2]);
            }
        }
        
        // 工事前のときは操作NG
        var tag = $(this).prop("tagName");
        if (mode == 0) {
            if (tag == "INPUT") {
                $(this).prop('readonly', true);
            }
            else if (tag == "SELECT") {
                $(this).prop('disabled', true);
            }
        }
    });
    
    $(root).find(".srcBefore").each(function() {
        $(this).attr('listNum', poleNum);

        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        var source = $(this).attr("source");
        $(this).val(completionModel.JointUseModels[line - 1].BeforeModelItems.ComSrcBeforeItems[source - 1][name]);
        
        // 工事後のときは操作NG
        var tag = $(this).prop("tagName");
        if (mode == 1) {
            if (tag == "INPUT") {
                $(this).prop('readonly', true);
            }
            else if (tag == "SELECT") {
                $(this).prop('disabled', true);
            }
        }
    });

    $(root).find(".after").each(function() {
        $(this).attr('listNum', poleNum);

        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        $(this).val(completionModel.JointUseModels[line - 1].AfterModelItems[name]);
        
        // 工事前のときは操作NG
        var tag = $(this).prop("tagName");
        if (mode == 0) {
            if (tag == "INPUT") {
                $(this).prop('readonly', true);
            }
            else if (tag == "SELECT") {
                $(this).prop('disabled', true);
            }
        }
    });

    $(root).find(".srcAfter").each(function() {
        $(this).attr('listNum', poleNum);

        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        var source = $(this).attr("source");
        $(this).val(completionModel.JointUseModels[line - 1].AfterModelItems.ComSrcAfterItems[source - 1][name]);
        
        // 工事前のときは操作NG
        var tag = $(this).prop("tagName");
        if (mode == 0) {
            if (tag == "INPUT") {
                $(this).attr('readonly', true);
            }
            else if (tag == "SELECT") {
                $(this).attr('disabled', true);
            }
        }
    });
    
    // 中電記入欄の表示
    // 机上調査の日付
    $(root).find(".chudenOffice").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.JointUseModels[line - 1].TechReviewResult["OfficeDate"];
        var strs = dateStr.split('/');
        
        if (strs.length == 3 && strs[0] != "") {
            if (num == 1) {
                $(this).val(String(Number(strs[0]) - 2018));
                if (String(Number(strs[0]) - 2018) == "0") {
                    $(this).val("");
                }
            }
            if (num == 2) {
                $(this).val(strs[1]);
            }
            if (num == 3) {
                $(this).val(strs[2]);
            }
        }
        
        $(this).attr('readonly', true);
    });
    
    // 現場調査の日付
    $(root).find(".chudenField").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.JointUseModels[line - 1].TechReviewResult["FieldData"];
        var strs = dateStr.split('/');
        
        if (strs.length == 3 && strs[0] != "") {
            if (num == 1) {
                $(this).val(String(Number(strs[0]) - 2018));
                if (String(Number(strs[0]) - 2018) == "0") {
                    $(this).val("");
                }
            }
            if (num == 2) {
                $(this).val(strs[1]);
            }
            if (num == 3) {
                $(this).val(strs[2]);
            }
        }
        
        $(this).attr('readonly', true);
    });
    
    // 改修工事完工日の日付
    $(root).find(".chudenRepair").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.JointUseModels[line - 1].TechReviewResult["RepairDate"];
        var strs = dateStr.split('/');
        
        if (strs.length == 3 && strs[0] != "") {
            if (num == 1) {
                $(this).val(String(Number(strs[0]) - 2018));
                if (String(Number(strs[0]) - 2018) == "0") {
                    $(this).val("");
                }
            }
            if (num == 2) {
                $(this).val(strs[1]);
            }
            if (num == 3) {
                $(this).val(strs[2]);
            }
        }
        
        $(this).attr('readonly', true);
    });
    
    // しゅん工後・実施日の日付
    $(root).find(".chudenAfterCompletion").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.JointUseModels[line - 1].TechReviewResult["AfterCompletionDate"];
        var strs = dateStr.split('/');
        
        if (strs.length == 3 && strs[0] != "") {
            if (num == 1) {
                $(this).val(String(Number(strs[0]) - 2018));
                if (String(Number(strs[0]) - 2018) == "0") {
                    $(this).val("");
                }
            }
            if (num == 2) {
                $(this).val(strs[1]);
            }
            if (num == 3) {
                $(this).val(strs[2]);
            }
        }
        
        $(this).attr('readonly', true);
    });
    
    // しゅん工後・改修期限の日付
    $(root).find(".chudenAfterDeadine").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.JointUseModels[line - 1].TechReviewResult["AfterDeadine"];
        var strs = dateStr.split('/');
        
        if (strs.length == 3 && strs[0] != "") {
            if (num == 1) {
                $(this).val(String(Number(strs[0]) - 2018));
                if (String(Number(strs[0]) - 2018) == "0") {
                    $(this).val("");
                }
            }
            if (num == 2) {
                $(this).val(strs[1]);
            }
            if (num == 3) {
                $(this).val(strs[2]);
            }
        }
        
        $(this).attr('readonly', true);
    });
    
    // 不適箇所・実施日の日付
    $(root).find(".chudenInadequate").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.JointUseModels[line - 1].TechReviewResult["InadequateDate"];
        var strs = dateStr.split('/');
        
        if (strs.length == 3 && strs[0] != "") {
            if (num == 1) {
                $(this).val(String(Number(strs[0]) - 2018));
                if (String(Number(strs[0]) - 2018) == "0") {
                    $(this).val("");
                }
            }
            if (num == 2) {
                $(this).val(strs[1]);
            }
            if (num == 3) {
                $(this).val(strs[2]);
            }
        }
        
        $(this).attr('readonly', true);
    });
    
    // 不適箇所・改修期限の日付
    $(root).find(".chudenInadequateDeadline").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.JointUseModels[line - 1].TechReviewResult["InadequateDeadline"];
        var strs = dateStr.split('/');
        
        if (strs.length == 3 && strs[0] != "") {
            if (num == 1) {
                $(this).val(String(Number(strs[0]) - 2018));
                if (String(Number(strs[0]) - 2018) == "0") {
                    $(this).val("");
                }
            }
            if (num == 2) {
                $(this).val(strs[1]);
            }
            if (num == 3) {
                $(this).val(strs[2]);
            }
        }
        
        $(this).attr('readonly', true);
    });
    
    // 中電記入欄の選択項目
    $(root).find(".chudenSelect").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        $(this).val(completionModel.JointUseModels[line - 1].TechReviewResult[name]);
    
        $(this).attr('disabled', true);
    });
    
    // 中電記入欄のチェックボックス
    $(root).find(".chudenCheck").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        var check = completionModel.JointUseModels[line - 1].TechReviewResult[name];
        console.log(name + ": " + check);
        
        // TODO: ここがBoolになってるので確認する
        if (check ==  true) {
            $(this).prop('checked', true);
        }
        else {
            $(this).prop('checked', false);
        }
        
        $(this).attr('disabled', true);
    });
    
    // 中電記入欄のテキスト箇所
    $(root).find(".chuden").each(function() {
        $(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        $(this).val(completionModel.JointUseModels[line - 1].TechReviewResult[name]);
        
        $(this).attr('readonly', true);
    });
    
    $(root).find(".imgSelect").each(function() {
        $(this).attr('listNum', poleNum);
    });
    
    // set image file
    loadImageSrc();
}

function getCheck() {
    $(root).find(".beforeCheck").each(function() {
        
        var name = $(this).attr("nameid");
        var check = $(this).prop('checked');
        if (check) {
            completionModel.JointUseModels[poleNum - 1].BeforeModelItems[name] = "true";
        }
        else {
            completionModel.JointUseModels[poleNum - 1].BeforeModelItems[name] = "false";
        }
    });
}

function getDate() {
    var y, m, d;
    if (mode == 0) {
        $(root).find(".beforePhoto").each(function() {
            if ($(this).val() != "") {
                var num = $(this).attr("num");
                if (num == 1) {
                    y = String(Number($(this).val()) + 2018);
                }
                if (num == 2) {
                    m = $(this).val();
                }
                if (num == 3) {
                    d = $(this).val();
                }
            }
        });
        completionModel.JointUseModels[poleNum - 1].BeforeModelItems["PhotoDate"] = y + "/" + m + "/" + d;
    }
    else if (mode == 1) {
        $(root).find(".afterPhoto").each(function() {
            if ($(this).val() != "") {
                var num = $(this).attr("num");
                if (num == 1) {
                    y = String(Number($(this).val()) + 2018);
                }
                if (num == 2) {
                    m = $(this).val();
                }
                if (num == 3) {
                    d = $(this).val();
                }
            }
        });
        completionModel.JointUseModels[poleNum - 1].AfterModelItems["PhotoDate"] = y + "/" + m + "/" + d;
    }
}

function gotoCamera(state) {
    console.log("gotoCamera: " + state);
    
    // save json
    // not need to save timestamp
    utilSaveJSON();
    
    // goto camera
    window.webkit.messageHandlers.gotoCamera.postMessage(state);
}

function loadImageSrc() {
    console.log("loadImageSrc");
    
    // load image src
    window.webkit.messageHandlers.loadImageSrc.postMessage("");
}

function setImageSrc(mode, base64) {
    console.log("setImageSrc: " + mode);
    
    var src = "data:image/jpeg;base64," + base64;
    
    if (mode == 0) {
        $(".photoBefore").children('img').attr('src', src);
    }
    else if (mode == 1) {
        $(".photoAfter").children('img').attr('src', src);
    }
}

function fromCamera() {
    // reload current completion
    loadCurrentData();
    
    // reload html
    console.log("reload html");
    location.reload();
}

// show image select dialog
function showImageDialog(val) {
    console.log("imgSelect: " + val);
    
    var cFile = "";
    if (val == 0) {
        cFile = completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoName;
    }
    else if (val == 1) {
        cFile = completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoName;
    }
    
    window.webkit.messageHandlers.setImageFiles.postMessage(cFile);
}

function setOption(file, fileName) {
    console.log("setImageFiles");
    
    files = file;
    
    // check option length
    var selectCount = $('#selectItems').children('option').length;
    if (selectCount == 0 || optionLen < files.length) {
        // set option
        files.forEach(function (file) {
            $('#selectItems').append($('<option>').html(file).val(file));
        });
        
        // set default value
        $('#selectItems').val(String(fileName));
        
        // temp option length
        optionLen = files.length;
    }
    
    // re-check option length
    selectCount = $('#selectItems').children('option').length;
    if (selectCount != 0) {
        // show dialog
        sDialog.showModal();
    }
}

