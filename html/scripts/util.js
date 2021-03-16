
// call save json to native
function utilSaveJSON() {
    console.log("utilSaveJSON");
    
    // get item data and update completion
    $(root).find(".joint").each(function() {
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        completionModel.JointUseModels[line - 1][name] = $(this).val();
    });
    
    $(root).find(".before").each(function() {
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        
        if (name == "Single" || name == "Bundling") {
            // ここでチェックボックスは取得しない
            // completion.js の getCheck() で取得している
        }
        else {
            completionModel.JointUseModels[line - 1].BeforeModelItems[name] = $(this).val();
        }
    });
    
    $(root).find(".srcBefore").each(function() {
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        var source = $(this).attr("source");
        completionModel.JointUseModels[line - 1].BeforeModelItems.ComSrcBeforeItems[source - 1][name] = $(this).val();
    });
    
    $(root).find(".after").each(function() {
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        completionModel.JointUseModels[line - 1].AfterModelItems[name] = $(this).val();
    });
    
    $(root).find(".srcAfter").each(function() {
        var line = $(this).attr("listNum");
        var name = $(this).attr("nameid");
        var source = $(this).attr("source");
        completionModel.JointUseModels[line - 1].AfterModelItems.ComSrcAfterItems[source - 1][name] = $(this).val();
    });
    
    // call save json to native
    console.log("call saveJSON");
    var s = JSON.stringify(completionModel);
    console.log("debug");
    window.webkit.messageHandlers.saveJSON.postMessage(s);
}

// call save timestamp to native
function utilSaveTimeStamp(lineNo, action) {
    console.log("utilSaveTimeStamp: " + lineNo + ", " + action);
    
    console.log("call saveTimeStamp");
    var s;
    
    if (action == 0)
        s = "Completion End,0";
    if (action == 1)
        s = "Completion Start,1";
    window.webkit.messageHandlers.saveTimeStamp.postMessage(s);
}
