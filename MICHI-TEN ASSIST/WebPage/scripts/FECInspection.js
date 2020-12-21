
var bgNormal = "#FFFFFF";
var bgEditMode = "#CEECF5";
var bgChangedItem = "#ffc0cb";

var oChangedList = [];

var v_FacilitySpecId = "";
var v_InspectionId = "";
var v_DamageLogId = "";
var v_TimeStampType_Log = 0;
var v_TimeStampType_Start = 1;
var v_TimeStampType_End = 2;


var v_fEdited = false;
var v_fEditMode = false;

var vf_btnStartEnd = false;
var v_imgStartBtnREDPath = "images/startend-red.png";
var v_imgStartBtnGreenPath = "images/startend-green.png";

var v_imgStartBtnStartPath = v_imgStartBtnGreenPath;
var v_imgStartBtnEndPath = v_imgStartBtnREDPath;


var v_btnStartedLineNumber = -1;
var v_fAlreadyGoOutside = false;

var fSelectOpen = false;

$(function () {
    loadCurrentInspectionData();
    initPage();

    showCorrection();

    ApplyApplicabable("#InspectionTable");
    // CheckApplicabable("#InspectionTable");

    $(".InspectionApplicable").change(function () {
        ApplyApplicabable($(this).parent().parent());
        // CheckApplicabable("#InspectionTable");
    });


    $("#btnGoAR").click(function () {
        if (!v_fAlreadyGoOutside )
        {
            v_fAlreadyGoOutside = true;

            disabled($("#btnGoAR"), true);
            GoAR();
        }
    });
    $("#btnGoFacility").click(function () {
        disabled($("#btnGoFacility"), true);
        GoFacility();
    });
    $("#btnEditStart").click(function () {
        StartEdit();
    });
    $("#btnEditEnd").click(function () {
        EndEdit();
    });
/*  20180612 Update3
    $("#btnCompleted").click(function () {
        completeInspection();
    });
*/
    $(".btnDamageLog").click(function () {
        GoDamageLog(this);
    });

    $(".InspectionData").change(function () {
        oChangedList.push(this);
        $(this).css("background-color",bgChangedItem);

        v_fEdited = true;
    });
    $(".DetailData").change(function () {
        oChangedList.push(this);
        $(this).css("background-color",bgChangedItem);

        v_fEdited = true;
    });
    $(".btnStartEnd").click(function () {
        var s = $(this).attr("iLine");
        var lineNumber = parseInt(s);
        var fStart = false;

        if (lineNumber != v_btnStartedLineNumber)
        {
            fStart = true;
        }

        // 2018-10-17
        ApplayApplicableLine($(this).parent().parent(), fStart, lineNumber, v_btnStartedLineNumber);

        EndInspectionBtn();
        if(fStart)
        {
            StartInspectionBtn(this, lineNumber);
        }
    });

    /*
    */
    $("select.InspectionData").focus(function () {
        var hTop = $("#idTop").height();
        var offsetTop = $(this).get(0).offsetTop;
        var st = offsetTop;
        if (0 < st)
        {
            $("body").animate({ scrollTop: st });
        }
//        $('#idScrollContent').css('position', 'fixed');
        fSelectOpen = true;
    });
    $("select.InspectionData").blur(function () {
//        $('#idScrollContent').css('position', 'relative');
        fSelectOpen = false;
    });
    $("select.InspectionData").change(function () {
//        $('#idScrollContent').css('position', 'relative');
        fSelectOpen = false;
    });

    AppendDeviceLog("Inspection Start", v_TimeStampType_Start, -1);

    // 2018-10-15
    //EditModeUI(false);

    // 2018-11-13
    setBgColor(false)
});


function showCorrection()
{
    var val = android.showCorrection();
    $("#correction").html("補正秒数 " + val + " 秒");
}


// 2018-10-17
function ApplayApplicableLine(o, fStart, lineValue, v_btnStartedLineNumber)
{
    $(o).parent().find(".btnStartEnd").each(function (){

        var aLineNum = $(this).attr("iLine");
        var oparent = $(this).parent().parent();

        if(!v_fEditMode){
            if(fStart)
            {
                if(aLineNum == v_btnStartedLineNumber)
                {
                    $(oparent).find(".valControl .DetailData").css("background-color", bgNormal);
                    disabled($(oparent).find(".valControl .DetailData"), true);
                    disabled($(oparent).find(".InspectionApplicable"), false);
                }

                if(aLineNum == lineValue)
                {
                    $(oparent).find(".valControl .DetailData").css("background-color", bgEditMode);
                    disabled($(oparent).find(".valControl .DetailData"), false);
                }
            }
            else
            {
                if(aLineNum == lineValue)
                {
                    $(oparent).find(".valControl .DetailData").css("background-color", bgNormal);
                    disabled($(oparent).find(".valControl .DetailData"), true);
                    disabled($(oparent).find(".InspectionApplicable"), false);
                }
            }
        }
    });

    $(".InspectionApplicable").css("background-color", bgEditMode);
}



function EndInspectionBtn()
{
    if(vf_btnStartEnd)
    {
        var s = v_btnStartedLineNumber.toString();
        var iLine = parseInt(s);
        if (0 <= iLine)
        {
            AppendDeviceLog("Inspection EndBtn", v_TimeStampType_End, iLine);
        }

        $(".DetailRow").each(function () {
            var lineNumber = $(this).attr("LineNumber");
            if (lineNumber == v_btnStartedLineNumber)
            {
                android.EndInspectionDetail(lineNumber);
                var oImg = $(this).find(".btnStartEnd");
                oImg.attr("src", v_imgStartBtnStartPath);
                v_btnStartedLineNumber = -1;
                vf_btnStartEnd = false;
                return;
            }
        });
    }
}
function StartInspectionBtn(o, linenumber)
{
    var s = linenumber.toString();
    var iLine = parseInt(s);
    AppendDeviceLog("Inspection StartBtn", v_TimeStampType_Start, iLine);
    android.StartInspectionDetail(linenumber);
    // PS 00001386
    $(o).attr("src", v_imgStartBtnEndPath);
    v_btnStartedLineNumber = linenumber;
    vf_btnStartEnd = true;
}



function initPage() {
    var h = $("#idTop").outerHeight();
    //$("#idScrollContent").css("margin-top", h.toString() + "px");


    v_fEdited = false;
    v_fEdited = false;
    disabledControls(true);
    disabled($("#btnEditEnd"), true);

    $("#idDebug").text(h);
}

function loadCurrentInspectionData() {
    var s = android.getInspectionData();
    var jsonInspectionFull = JSON.parse(s);
    var jsonInspectionPrimary = jsonInspectionFull["Inspection"];

    v_FacilitySpecId =jsonInspectionPrimary["FacilitySpecId"];
    v_InspectionId = jsonInspectionPrimary["InspectionId"];
    v_DamageLogId = v_constGUIDEmpty;
//    v_LineNumber = -1;

    $(".InspectionData").each(function () {
        var dtype = $(this).attr("dataType");
        var id = $(this).attr("id");
        var v = jsonInspectionPrimary[id];
        if (null == v)
            v = "";
        if (dtype == "text")
        {
            $(this).text(v);
        }
        else if (dtype == "val") {
            $(this).val(v);
        }
    });
    var jsonInspectionDetails = jsonInspectionFull["InspectionDetails"];
// xinglang 2020/12/14 点検結果票その他常に４行にする　start
// xinglang 2020/11/25 点検結果票その他空白を1行残す　start
//    var flag = false;
// xinglang 2020/11/25 点検結果票その他空白を1行残す　end
// xinglang 2020/12/14 点検結果票その他常に４行にする　end
    
    $(".DetailRow").each(function () {
        var LineNumber = $(this).attr("LineNumber");
        var oInspectionDetail = null;
        for (var i = 0 ; i < jsonInspectionDetails.length ; i++) {
            if (jsonInspectionDetails[i].LineNumber == LineNumber) {
                oInspectionDetail = jsonInspectionDetails[i];
// xinglang 2020/11/25 点検結果票その他空白を1行残す　start
//                if(i>=31 && i<=33){
//                    if(jsonInspectionDetails[i].InspectionPoint == ""){
//                        if(flag){
//                            $(this).hide();
//                        }
//                        else{
//                            $(this).find(".lws-C2").removeClass("FEC-ItemColNB");
//                            $(this).find(".lws-CInsParts").removeClass("FEC-ItemColNB");
//                            flag = true;
//                        }
//                    }
//                }
// xinglang 2020/11/25 点検結果票その他空白を1行残す　end
                
// xinglang 2020/12/14 点検結果票その他常に４行にする　start
                if(i==31){
                    $(this).find(".lws-C2").removeClass("FEC-ItemColNB");
                    $(this).find(".lws-CInsParts").removeClass("FEC-ItemColNB");
                }
                if(i == 32 || i == 33){
                    $(this).hide();
                }
// xinglang 2020/12/14 点検結果票その他常に４行にする　end
                break;
            }
        }
        var DetailDatas = $(this).find(".DetailData").each(function () {
            var dtype = $(this).attr("dataType");
            var id = $(this).attr("dataId");
            var v = oInspectionDetail[id];

            if (null == v)
                v = "";
            if (dtype == "text") {
                $(this).text(v);
            }
            else if (dtype == "val") {

                // 2018-10-18
                if(v == "" && /Before/.test(id))
                {
                    v = "a";
                }

                $(this).val(v);
            }
        });
    });

    $(".InspectionApplicable").change(function () {
        ApplyApplicabable($(this).parent().parent());
    });
    ApplyApplicabable("#InspectionTable")

}

function ApplyMask(o)
{
    $(o).find(".valACE").each(function () {
        var f = $(this).attr("mask");
        if (!f) {
            $(this).css('background-color', "#a9a9a9");
        }
    });
}

function ApplyApplicabable(o)
{
    $(o).find(".InspectionApplicable").each(function () {
        var v = $(this).val();
        if (v != "有") {
            var oparent = $(this).parent().parent();

            // set bgColor to gray
            $(oparent).find(".valACE").css('background-color', "#a9a9a9");
            $(oparent).find(".valACE .DetailData").hide();

            // set Inspection Status to empty
            $(oparent).find(".InspectionStatus").hide();
            $(oparent).find(".InspectionStatus").parent().css('background-color', "#a9a9a9");

            $(oparent).find(".btnDamageLog").attr("btnAvailable", "0");

            $(oparent).find(".btnStartEnd").hide();
        }
        else
        {
            var oparent = $(this).parent().parent();

            // set bgColor to gray
            $(oparent).find(".valACE").css('background-color', "#ffffff");
            $(oparent).find(".valACE .DetailData").show();

            // set Inspection Status to empty
            $(oparent).find(".InspectionStatus").show();
            $(oparent).find(".InspectionStatus").parent().css('background-color', "#ffffff");
            ApplyMask(oparent);
            $(oparent).find(".btnDamageLog").attr("btnAvailable", "1");

            $(oparent).find(".btnStartEnd").show();
        }
    });
}


function CheckApplicabable(o){
    var array = [];
    $(o).find(".InspectionApplicable").each(function () {
        var v = $(this).val();
        array.push(v);
    });
//    console.log(array);

    var result = array.slice(0, 12).every( function( value ) {
        return value == "無";
    });
//    console.log(array.slice(0, 12));
//    console.log(result);
    if(result){
        $("#StanchionSolve").val(0)
        $("#StanchionSolve").css("background-color",bgChangedItem);
        $("#StanchionHealth").val(0)
        $("#StanchionHealth").css("background-color",bgChangedItem);
    }
    var result = array.slice(12, 18).every( function( value ) {
        return value == "無";
    });
//    console.log(array.slice(12, 18));
//    console.log(result);
    if(result){
        $("#CrossbeamSolve").val(0)
        $("#CrossbeamSolve").css("background-color",bgChangedItem);
        $("#CrossbeamHealth").val(0)
        $("#CrossbeamHealth").css("background-color",bgChangedItem);
    }
    var result = array.slice(18, 24).every( function( value ) {
        return value == "無";
    });
//    console.log(array.slice(18, 24));
//    console.log(result);
    if(result){
        $("#SignAttachmentSolve").val(0)
        $("#SignAttachmentSolve").css("background-color",bgChangedItem);
        $("#SignAttachmentHealth").val(0)
        $("#SignAttachmentHealth").css("background-color",bgChangedItem);
    }
    var result = array.slice(24, 26).every( function( value ) {
        return value == "無";
    });
//    console.log(array.slice(24, 26));
//    console.log(result);
    if(result){
        $("#BaseSolve").val(0)
        $("#BaseSolve").css("background-color",bgChangedItem);
        $("#BaseHealth").val(0)
        $("#BaseHealth").css("background-color",bgChangedItem);
    }
    var result = array.slice(26, 28).every( function( value ) {
        return value == "無";
    });
//    console.log(array.slice(26, 28));
//    console.log(result);
    if(result){
        $("#BracketSolve").val(0)
        $("#BracketSolve").css("background-color",bgChangedItem);
        $("#BracketHealth").val(0)
        $("#BracketHealth").css("background-color",bgChangedItem);
    }
    var result = array.slice(28).every( function( value ) {
        return value == "無" || value == null;
    });
//    console.log(array.slice(28));
//    console.log(result);
    if(result){
        $("#OtherSolve").val(0)
        $("#OtherSolve").css("background-color",bgChangedItem);
        $("#OtherHealth").val(0)
        $("#OtherHealth").css("background-color",bgChangedItem);
    }
}



function saveInspectionPrimaryData(fSave) {
    if (v_fEdited) {
        var jsonData = {};
        $(".InspectionData").each(function () {
            var dataType = $(this).attr("dataType");
            if (dataType == "val")
            {
                var field = $(this).attr("id");
                var v = $(this).val();
                jsonData[field] = v;
            }
        });
        var s = JSON.stringify(jsonData);
        android.savetInspectionPrimaryData(s, fSave);
        if (fSave) {
            v_fEdited = false;
        }
    }

}
function saveInspectionDetailData(fSave) {
    if (v_fEdited) {
        var jsonData = {
            items: []
        };

        //
        $(".DetailRow").each(function () {
            var jsonItem = {};
            $(this).find(".DetailData").each(function () {
                var field = $(this).attr("dataId");
                var dataType = $(this).attr("dataType");
                if (dataType == "val")
                {
                    var v = $(this).val();
                    jsonItem[field] = v;
                }
            });
            jsonData.items.push(jsonItem);
        });

        var s = JSON.stringify(jsonData);
        android.savetInspectionDetailData(s, fSave);
        if (fSave) {
            v_fEdited = false;
        }
    }
}

function disabledControls(f) {
    // 2018/10/16
//    disabled($(".InspectionData"), f);

    disabled($(".DetailData"), f);

    // 2018-10-16
    disabled($(".InspectionApplicable"), false);
}

function setBgColor(fEditMode) {
    if (fEditMode) {
/*
        $(".InspectionData").each(function () {
            var dataType = $(this).attr("dataType");
            if(dataType == "val")
            {
                $(this).css("background-color", bgEditMode);
            }
        });
*/
        $(".valControl .DetailData").each(function () {
            var dataType = $(this).attr("dataType");
            if(dataType == "val")
            {
                $(this).css("background-color", bgEditMode);
            }
        });
    }
    else {
        // 2018/10/16
//        $(".InspectionData").css("background-color", bgNormal);

        $(".InspectionData").each(function () {
            var dataType = $(this).attr("dataType");
            if(dataType == "val")
            {
                $(this).css("background-color", bgEditMode);
            }
        });

        $(".valControl .DetailData").css("background-color", bgNormal);

        // 2018/10/16
        $(".InspectionApplicable").css("background-color", bgEditMode);
    }
    $.each(oChangedList , function (i, v) {
        var o = oChangedList[i];
       $(o).css("background-color",bgChangedItem);
    });

}

/*
$(function () {
  // セレクトボックス毎に処理
  $('select').each(function(i){

    // data-selectを追加
    $(this).attr('id', 'select'+i);

    // セレクトボックスの内容をモーダルウィンドウにコピー
    var clone = $(this).clone().appendTo($(this).parent());
    var remodal_clone = $(clone).wrap('<div data-remodal-id="remodal-select'+i+'" class="remodal remodal-select"></div>').after('<button data-remodal-action="close" class="remodal-close bottom-close">閉じる</button>');

    $(remodal_clone).children('option').each(function(){
      var tag_value = $(this).attr("value");
      if ( tag_value == "") {
        $(this).replaceWith('');
      } else {
        var tag_value_plus = 'data-value="'+tag_value+'"';
        $(this).replaceWith('<li '+tag_value_plus+'>'+$(this).html()+'</li>');
      }
    });
    $(remodal_clone).each(function(){
      $(this).replaceWith('<ul>'+$(this).html()+'</ul>');
    });

    // 元のセレクトボックスは非表示
    $(this).css('display','none');

    // 選択中のoption情報取得
    var selected = $(this).find(':selected');
    var selected_val = $(selected).val();
    var selected_text = $(selected).text();
    //$('a[href = "#remodal-select'+i+'"]').text(selected_text);

    // モーダルウィンドウを開くリンク生成
    $(this).after('<a href="#remodal-select'+i+'" class="remodal-select-open">'+selected_text+'</a>');

  });

  // モーダルウィンドウの中をクリックした時の動作
  $('.remodal-select').each(function(i){
    var select_id = $(this).data('select');

    $(this).find('li').on('click', function() {

      var text = $(this).text();
      var value = $(this).data('value');

      $('#select'+i).val([value]);

      $('a[href = "#remodal-select'+i+'"]').text(text);

      // class付与
      $(this).siblings().removeClass("selected");
      $(this).addClass("selected");
      $(function() {
        $('[data-remodal-id=remodal-select'+i+']').remodal().close();
      });
    });

  });
});
*/


function EditModeUI(fEditMode) {
    if (fEditMode) {
        v_fEditMode = true;
        disabledControls(false);
        disabled($("#btnEditStart"), true);
        disabled($("#btnEditEnd"), false);
    }
    else {
        v_fEditMode = false;
        disabledControls(true);
        disabled($("#btnEditStart"), false);
        disabled($("#btnEditEnd"), true);
    }
    setBgColor(fEditMode);
}
function GoAR() {
    EndInspectionBtn();
    saveInspectionDetailData(false);
    saveInspectionPrimaryData(true);
    //    saveFacilityData();
    v_fEditMode = false;
    AppendDeviceLog("Inspection End Go AR", v_TimeStampType_End, -1);
    android.go_ar();
}

function GoFacility() {
    EndInspectionBtn();
    saveInspectionPrimaryData(false);
    saveInspectionDetailData(true);
    v_fEditMode = false;
    AppendDeviceLog("Inspection End Go Facility", v_TimeStampType_End, -1);

    //	android.go_InspectionFromFacility();
    android.go_Facirity();

    location.href = "facility.html";

}

function GoDamageLog(o)
{
    EndInspectionBtn();
    AppendDeviceLog("Inspection End Go DamageLog", v_TimeStampType_End, -1);
    var IsBtnAvailable = $(o).attr('btnAvailable');
    if (IsBtnAvailable == "1")
    {
        var lineNumber =  $(o).attr('LineNumber');
        saveInspectionDetailData(false);
        saveInspectionPrimaryData(true);
        v_fEditMode = false;
        android.go_DamageLog(lineNumber);
        location.href = "DamageLog.html";
    }
}


function StartEdit() {
    EndInspectionBtn();
    EditModeUI(true);
}

function EndEdit() {
    EndInspectionBtn();
    saveInspectionDetailData(false);
    saveInspectionPrimaryData(true);
    v_fEditMode = false;
    EditModeUI(false);

}


function completeInspection() {
    EndInspectionBtn();
    saveInspectionDetailData(false);
    saveInspectionPrimaryData(true);
    EndEdit();
    android.fix_from_shogen();
}


function AppendDeviceLog(Action, TimeStampType, linenum)
{
    android.appendDeviceLog(v_FacilitySpecId, v_InspectionId, v_DamageLogId, linenum, Action, TimeStampType);
}


$(function() {
  var $win = $(window),
      $main = $('main'),
      $nav = $('nav'),
      navHeight = $nav.outerHeight(),
      footerHeight = $('footer').outerHeight(),
      docmentHeight = $(document).height(),
      navPos = $nav.offset().top,
      fixedClass = 'is-fixed',
      hideClass = 'is-hide';

  $win.on('load scroll', function() {
    var value = $(this).scrollTop(),
        scrollPos = $win.height() + value;

    if ( value > navPos ) {
      if ( docmentHeight - scrollPos <= footerHeight - 300 ) {
        $nav.addClass(hideClass);
      } else {
        $nav.removeClass(hideClass);
      }
      $nav.addClass(fixedClass);
      $main.css('margin-top', navHeight);
    } else {
      $nav.removeClass(fixedClass);
      $main.css('margin-top', '0');
    }
  });
});
