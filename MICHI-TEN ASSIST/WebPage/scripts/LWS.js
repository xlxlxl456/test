var v_constHoverRowBG = "#87cefa";
var v_constSelectedRowBG = "#0175C2";
var v_constSelectedRowFC = "#ffffff";
var v_constGUIDEmpty = "00000000-0000-0000-0000-000000000000";
var v_constGUIDEmptyId = "#00000000-0000-0000-0000-000000000000";

var v_updateTarget = null;
function disabled(o, f) {
    if (f) {
        $(o).prop('disabled', true);
    }
    else {
        $(o).prop('disabled', false);
    }
}

var v_AjaxButton = null;
function AjaxFailed(xhr, status, error) {
    ModalWaitEnd();
//    ModalProgressEnd();
    var s = "Unexpected error!!";
    if (null != error && 0 < error.length) {
        s = decodeURI(error);
    }
    s = s.replace(/\+/g, " " );
    alert(s);

    if (null != v_AjaxButton) {
        if (0 < $(v_AjaxButton).length) {
            $(v_AjaxButton).removeAttr("disabled");
        }
        v_AjaxButton = null;
    }
}

var v_selected = null;
function tblRowSelectorCol(o)
{
    v_selected = null;
    $(o).find(".lwsListItem").each(function () {
        $(this).prop('orgBG', $(this).css('background-color'));
        $(this).prop('orgFC', $(this).css('color'));
    });

    $(o).find(".lwsListItemCol").hover(
        function () {
            var _o = $(this).parent();
            var seletedId = null;
            if (null != v_selected) {
                seletedId = $(v_selected).attr("id");
            }
            var currentId = $(_o).attr("id");
            if (seletedId != currentId) {
                $(_o).css('background-color', v_constHoverRowBG);
                $(_o).css('color', $(_o).prop('orgFC'));
            }
        },
        function () {
            var _o = $(this).parent();
            var seletedId = null;
            if (null != v_selected)
            {
                seletedId = $(v_selected).attr("id");
            }
            var currentId = $(_o).attr("id");
            if (seletedId != currentId) {
                $(_o).css('background-color', $(_o).prop('orgBG'));
                $(_o).css('color', $(_o).prop('orgFC'));
            }
        }
    );
    $(o).find(".lwsListItemCol").click(function () {
        ListSelectBehavior($($(this).parent()));
    });
}


function tblRowSelector(o) {
    v_selected = null;
    $(o).find(".lwsListItem").each(function () {
        $(this).prop('orgBG', $(this).css('background-color'));
        $(this).prop('orgFC', $(this).css('color'));
    });

    $(o).find(".lwsListItem").hover(
        function () {
            var _o = $(this);
            var seletedId = null;
            if (null != v_selected) {
                seletedId = $(v_selected).attr("id");
            }
            var currentId = $(_o).attr("id");
            if (seletedId != currentId) {
                $(_o).css('background-color', v_constHoverRowBG);
                $(_o).css('color', $(_o).prop('orgFC'));
            }
        },
        function () {
            var _o = $(this);
            var seletedId = null;
            if (null != v_selected) {
                seletedId = $(v_selected).attr("id");
            }
            var currentId = $(_o).attr("id");
            if (seletedId != currentId) {
                $(_o).css('background-color', $(_o).prop('orgBG'));
                $(_o).css('color', $(_o).prop('orgFC'));
            }
        }
    );
    $(o).find(".lwsListItem").click(function () {
        ListSelectBehavior($(this));
    });
}

function ListSelectBehavior(o) {
    if (null != v_selected) {
        $(v_selected).css('background-color', $(v_selected).prop('orgBG'));
        $(v_selected).css('color', $(v_selected).prop('orgFC'));
    }
    v_selected = o;
    $(o).css('background-color', v_constSelectedRowBG);
    $(o).css('color', v_constSelectedRowFC);
}
function ListSelectBehavior2(parent, firstId, idPreset) {
    var id = "#" + idPreset + $(parent).find(firstId).val();
    if (id != v_constGUIDEmptyId) {
        var o = $(parent).find(id);
        ListSelectBehavior(o);
    }
}

/**********/
function tblRowSelectorX(o) {
    $(o).prop('selectedItem', null);
    $(o).find(".lwsListItem").each(function () {
        $(this).prop('orgBG', $(this).css('background-color'));
        $(this).prop('orgFC', $(this).css('color'));
        $(this).prop('listOwner', o);
    });
    $(o).find(".lwsListItem").hover(
        function () {
            var _o = $(this);
            var _parent = $(this).prop('listOwner');
            var _v_seletedId = $(_parent).prop('selectedItem');
            var seletedId = null;
            if (null != _v_seletedId) {
                seletedId = $(_v_seletedId).attr("id");
            }
            var currentId = $(_o).attr("id");
            if (seletedId != currentId) {
                $(_o).css('background-color', v_constHoverRowBG);
                $(_o).css('color', $(_o).prop('orgFC'));
            }
        },
        function () {
            var _o = $(this);
            var _parent = $(this).prop('listOwner');
            var _v_seletedId = $(_parent).prop('selectedItem');
            var seletedId = null;
            if (null != _v_seletedId) {
                seletedId = $(_v_seletedId).attr("id");
            }
            var currentId = $(_o).attr("id");
            if (seletedId != currentId) {
                $(_o).css('background-color', $(_o).prop('orgBG'));
                $(_o).css('color', $(_o).prop('orgFC'));
            }
        }
    );
    $(o).find(".lwsListItem").click(function () {
        ListSelectBehaviorX(this);
    });
}

function ListSelectBehaviorX(o) {
    var _parent = $(o).prop('listOwner');
    var _v_seletedId = $(_parent).prop('selectedItem');
    if (null != _v_seletedId) {
        $(_v_seletedId).css('background-color', $(_v_seletedId).prop('orgBG'));
        $(_v_seletedId).css('color', $(_v_seletedId).prop('orgFC'));
    }
    $(_parent).prop('selectedItem', o);
    $(o).css('background-color', v_constSelectedRowBG);
    $(o).css('color', v_constSelectedRowFC);
}



/**********/
var v_oResizeElm = null;
var v_minusOffset = -1;
var v_minHeght = 100;

$(window).on('load resize', function () {
    smartHeight();
//    adJustFooter();
});


function adJustFooter()
{
    if (0 < $("#footer").length)
    {
        var hTotal = $(window).height() - $("#footer").outerHeight();
        var footerTop = $("#footer").offset().top;
        var sfm = $("#footer").css("margin-top");
        var fm = parseInt(sfm.replace("px", ""));
        var mb = hTotal - footerTop + fm;
        if (mb < 10)
            mb = 10;
        $("#footer").css("margin-top", mb.toString() + "px");
    }
}



function smartHeightInit(o, minusOffset, minHeight)
{
    v_oResizeElm = o;
    v_minusOffset = minusOffset;
    v_minHeght = minHeight;
    smartHeight();
}
function smartHeight()
{
    var hTotal = $(window).height() - $("#footer").outerHeight() - 48 /*footer top margin*/;
    $(".htype01").each(function (i, elem) {
        var top = $(this).offset().top;
        var parentContainerId = "#" + $(this).attr("parentContainer");
        var hBottom = $(parentContainerId).find(".bottomPart").outerHeight()
        var h = hTotal - top - hBottom;
        $(this).height(h);
    });
    adJustFooter();
}

var mstatus = 0;
function ModalWaitStart() {
    if (mstatus == 0) {
        $('#idModalWait').modal('show');
        mstatus += 1;
    }
}
function ModalWaitEnd() {
    if (mstatus == 1) {
        $('#idModalWait').modal('hide');
        mstatus -= 1;
    }

}

function readyDownload(fileId) {
    ModalWaitEnd();
    var o = $("#idDownload");
    $(o).find("#fileId").val(fileId);
    $(o).submit();
}


/*------------------------------
ProgressBar Control
------------------------------*/
var checkProgressTimer = null;
var vid_completeAction = null;
var ShowProgressRecordStatus = false;
function StartProgress() {
    $('#idModalProgressBar').css('width', '0%');
    $('#idModalProgressBar').text('0%');
    checkProgressTimer = setInterval(function () {
        CheckProgress();
    }, 2000);
}

function CheckProgress() {
    $("#idCheckProgress").submit();
}

function CheckProgressResult(data) {

    var result = data.result;
    var iProgress = data.iProgress;
    var RecordCur = data.RecordCur;
    var TotalRecord = data.TotalRecord;
    var message = data.message;

    if (2 == result || 3 == result/* || 100 == iProgress */) {
        if (null != checkProgressTimer)
            clearInterval(checkProgressTimer);
        ModalProgressEnd();
        if (null != message && 0 < message.length) {
            alert(message);
        }
        if (3 != result && null != vid_completeAction) {
            $(vid_completeAction).submit();
        }
        var newProcessId = data.newProcessId;
        $("#processId").val(newProcessId);
        $("#progressCheckId").val(newProcessId);
    }
    else {
        $('#idModalProgressBar').css('width', iProgress + '%');
        var progressText = iProgress + '%';
        if (ShowProgressRecordStatus) {
            progressText += ("    (" + RecordCur + " / " + TotalRecord + ")");
        }
        $('#idModalProgressBar').text(progressText);
    }
}

function ModalProgressStart() {
    $('#idModalProgress').modal('show');
}
function ModalProgressEnd() {
    if (null != checkProgressTimer) {
        clearInterval(checkProgressTimer);
        checkProgressTimer = null;
    }
    $('#idModalProgress').modal('hide');
}
