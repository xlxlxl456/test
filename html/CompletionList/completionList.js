var completionModel = null;
var poleNum = -1;
var root = null;

$(function () {
    root = this;
    
    // load current completionModel
    loadCurrentData();
    
    // save json
    $(".save").click(function () {
        // get before/after date
        getDate();
        
        // save json
        utilSaveJSON();
    });
    
    // goto workList
    $(".workList").click(function () {
        loadWorkList();
    });
    
    // goto completion
    $(".linkNo").click(function () {
        var lineNo = $(this).attr("lineNo");
        loadCompletion(lineNo);
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

// call load current completionModel to native
function loadCurrentData() {
    console.log("loadCurrentData");
    window.webkit.messageHandlers.loadCurrentData.postMessage("");
}

// get current completionModel from native
function setCurrentData(json) {
    console.log("setCurrentData");
    completionModel = json;
    
    // show list
    setList();
}

// set data on list
function setList() {
    console.log("setList " + root);
    
    var mode = completionModel.WorkState;
    
    // リストでは撮影日を変更させない
//    $(root).find(".beforePhoto").each(function() {
//        $(this).attr('readonly', true);
//    });
//    $(root).find(".afterPhoto").each(function() {
//        $(this).attr('readonly', true);
//    });
    
    $(root).find(".completion").each(function() {
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        $(this).val(completionModel[name].replace("営業所", ""));
    });
    
    $(root).find(".joint").each(function() {
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
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        $(this).val(completionModel.JointUseModels[line - 1].BeforeModelItems[name]);
        
        // 2. 共架予定位置のチェックに合わせてテキストを変化
        if (name == "Single") {
            if ($(this).val() != "true") {
                $(root).find(".before_single").each(function() {
                    var line2 = $(this).attr("listNum");
                    if (line == line2) {
                        $(this).hide();
                    }
                });
            }
        }
        if (name == "Bundling") {
            if ($(this).val() != "true") {
                $(root).find(".before_bundling").each(function() {
                    var line2 = $(this).attr("listNum");
                    if (line == line2) {
                        $(this).hide();
                    }
                });
            }
        }
        
        // 工事後のときは操作NG
        // HTMLタグを取得
        var tag = $(this).prop("tagName");
        if (mode == 1) {
            // input tag
            if (tag == "INPUT") {
                $(this).prop('readonly', true);
            }
            // select tag
            else if (tag == "SELECT") {
                $(this).prop('disabled', true);
            }
        }
    });
    
    $(root).find(".srcBefore").each(function() {
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
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        var source = $(this).attr("source");
        $(this).val(completionModel.JointUseModels[line - 1].AfterModelItems.ComSrcAfterItems[source - 1][name]);
        
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
    
    $(root).find(".workBeforeDate").each(function() {
        //$(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.WorkBeforeDate;
        var strs = dateStr.split('/');
        
        if (strs.length == 3) {
            if (strs[0] != "0" || strs[1] != "0" || strs[2] != "0") {
                if (num == 1) {
                    $(this).val(String(Number(strs[0]) - 2018));
                }
                if (num == 2) {
                    $(this).val(String(Number(strs[1])));
                }
                if (num == 3) {
                    $(this).val(String(Number(strs[2])));
                }
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
    
    $(root).find(".workAfterDate").each(function() {
        //$(this).attr('listNum', poleNum);
        
        var line = $(this).attr("listNum");
        var num = $(this).attr("num");
        var dateStr = completionModel.WorkAfterDate;
        var strs = dateStr.split('/');
        
        if (strs.length == 3) {
            if (strs[0] != "0" || strs[1] != "0" || strs[2] != "0") {
                if (num == 1) {
                    $(this).val(String(Number(strs[0]) - 2018));
                }
                if (num == 2) {
                    $(this).val(String(Number(strs[1])));
                }
                if (num == 3) {
                    $(this).val(String(Number(strs[2])));
                }
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
}

// goto completion.html
function loadCompletion(lineNo) {
    console.log("loadCompletion: " + lineNo);
    
    // set pole number
    window.webkit.messageHandlers.setPoleNum.postMessage(lineNo);
    
    // get before/after date
    getDate();
    
    // save json
    utilSaveJSON();
    
    // save timestamp
    utilSaveTimeStamp(lineNo, 1);
    
    // call goto completion.html
    window.webkit.messageHandlers.loadHtml.postMessage("completion");
}

// goto workList.html
function loadWorkList() {

    // get before/after date
    getDate();
    
    // save
    utilSaveJSON();
    
    // call goto completion.html
    window.webkit.messageHandlers.loadHtml.postMessage("workList");
}

function getDate() {
    var y, m, d;
    $(root).find(".workBeforeDate").each(function() {
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
        else {
            y = 0;
            m = 0;
            d = 0;
        }
    });
    completionModel.WorkBeforeDate = y + "/" + m + "/" + d;
    
    $(root).find(".workAfterDate").each(function() {
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
        else {
            y = 0;
            m = 0;
            d = 0;
        }
    });
    completionModel.WorkAfterDate = y + "/" + m + "/" + d;
}
