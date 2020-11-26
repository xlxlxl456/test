
var disabledEvalMasks = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0],    /* line 0 : dummy*/

    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 1:支柱本体 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 2:支柱継手部 */
    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 3:支柱分岐部 */
    [1, 1, 1, 0, 0, 1, 1, 0, 0],    /* line 4:支柱内部 */

    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 5:リブ・取付溶接部 */
    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 6:柱・ベースプレート溶接部 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 7:ベースプレート取付部 */
    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 8:路面境界部（ＧＬ-0） */
    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 9:路面境界部（ＧＬ-40） */
    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 10:柱・基礎境界部 */

    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 11:電気設備用開口部 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 12:開口部ボルト */

    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 13:横梁本体 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 14:横梁取付部 */
    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 15:横梁トラス本体 */
    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 16:横梁仕口溶接部 */
    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 17:横梁トラス溶接部 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 18:横梁継手部 */

    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 19:標識板（添架含む） */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 20:標識板取付部 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 21:道路情報板 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 22:道路情報板取付部 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 23:灯具 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 24:灯具取付部 */

    [1, 1, 1, 1, 0, 0, 0, 0, 0],    /* line 25:基礎コンクリート部 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 26:アンカーボルト・ナット */

    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 27:ブラケット本体 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 28:ブラケット取付部 */

    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 29:バンド部（共架型） */
    [0, 1, 1, 0, 0, 1, 1, 1, 0],    /* line 30:配線部分 */
    [0, 0, 0, 0, 0, 1, 1, 1, 0],    /* line 31:管理用の足場・作業台 */

    [0, 0, 0, 0, 0, 0, 0, 0, 0],    /* line 32*/
    [0, 0, 0, 0, 0, 0, 0, 0, 0],    /* line 33*/
    [0, 0, 0, 0, 0, 0, 0, 0, 0]    /* line 34*/

];

var v_FacilitySpecId = "";
var v_InspectionId = "";
var v_DamageLogId = "";
var v_TimeStampType_Log = 0;
var v_TimeStampType_Start = 1;
var v_TimeStampType_End = 2;

var v_dataFolderPath = null;
var v_lineNumber = 1;
var v_SpecialNote = null;
var v_DamageLog = null;
var v_ImagesCur = null;
var v_SerialNumber = null;

var v_SelectedStatus = 0;


var bgNormal = "#FFFFFF";
var bgEditMode = "#CEECF5";
var bgChangedItem = "#ffc0cb";

var oChangedList = [];



var v_fEdited = false;
var v_fEditMode = false;
var fSelectOpen = false;

var v_fAlreadyGoOutside = false;

$(function () {

    loadCurrentData();

    showImages();

    var LineNumber = v_lineNumber;
    var disabledEval = disabledEvalMasks[LineNumber];
    $(".InspectionEval").each(function () {
        $(this).find(".Eval").each(function (index) {
            if (disabledEval[index] == 1)
            {
                $(this).find(".InspectionData").hide();
                $(this).css('background-color', "#a9a9a9");
            }
        });
    });
    initPage();

    showCorrection();

    $("#btnGoAR").click(function () {
        if (!v_fAlreadyGoOutside)
        {
            v_fAlreadyGoOutside = true;
            disabled($("#btnGoAR"), true);
            android.setEditMode(false);
            AppendDeviceLog("DamageLog End Go AR", v_TimeStampType_End);
            GoAR();
        }
    });
    $("#btnGoFacility").click(function () {
        if (!v_fAlreadyGoOutside)
        {
            v_fAlreadyGoOutside = true;
            disabled($("#btnGoFacility"), true);
            android.setEditMode(false);
            AppendDeviceLog("DamageLog End Go Facility", v_TimeStampType_End);
            GoFacility();
        }
    });
    $("#btnGoInspection").click(function () {
        if (!v_fAlreadyGoOutside)
        {
            v_fAlreadyGoOutside = true;
            disabled($("#btnGoInspection"), true);
            android.setEditMode(false);
            AppendDeviceLog("DamageLog End Go Inspection", v_TimeStampType_End);
            GoInspection();
        }
    });
    $("#btnEditStart").click(function () {
        StartEdit();
    });
    $("#btnEditEnd").click(function () {
        EndEdit();
        android.setEditMode(false);
    });

    $(".InspectionData").change(function () {
        oChangedList.push(this);
        $(this).css("background-color",bgChangedItem);
        v_fEdited = true;
    });
    $(".DamageLogImgCaption").change(function () {
        oChangedList.push(this);
        $(this).css("background-color",bgChangedItem);
        v_fEdited = true;
    });
    $(".btnSelectImg").click(function () {
        v_SelectedStatus = $(this).attr("SelectedStatus");
        ShowImgSelector();
    });
    $(".DamageLogImg").click(function () {
        android.setEditMode(v_fEditMode);
        if (v_fEditMode)
        {
            if (!v_fAlreadyGoOutside)
            {
                v_fAlreadyGoOutside = true;
                saveData();
                var SelectedStatus = $(this).attr("SelectedStatus");
                android.goto_camera_mode(SelectedStatus);
            }
        }
    });
    // Image Selector
    $("#pBtn_OK").click(function () {
        setImage();
    });
    // Update3
    if(android.IsEditMode())
    {
        StartEdit();
    }
    else
    {
        AppendDeviceLog("DamageLog Start",v_TimeStampType_Start);
    }

});
function initPage() {
    var h = $("#idTop").outerHeight();
    $("#idScrollContent").css("margin-top", h.toString() + "px");
    v_fEdited = false;
    v_fEditMode = false;
    disabledControls(true);
    disabled($("#btnEditEnd"), true);

}


function showCorrection()
{
    var val = android.showCorrection();
    $("#correction").html("補正秒数 " + val + " 秒");
}


function disabledControls(f) {
    disabled($(".InspectionData"), f);
    disabled($(".DamageLogImgCaption"), f);
    disabled($(".btnSelectImg"), f);
}
function setBgColor(fEditMode) {
    if (fEditMode) {
        $(".InspectionData").each(function () {
            var dataType = $(this).attr("dataType");
            if(dataType == "val")
            {
                $(this).css("background-color", bgEditMode);
            }
        });
        $(".DamageLogImgCaption").css("background-color", bgEditMode);
    }
    else {
        $(".InspectionData").css("background-color", bgNormal);
        $(".DamageLogImgCaption").css("background-color", bgNormal);
    }
    $.each(oChangedList , function (i, v) {
        var o = oChangedList[i];
       $(o).css("background-color",bgChangedItem);
    });
}


function loadCurrentData()
{
    v_dataFolderPath = android.getDataFolder();

    var s = android.getDamageLogData();

    var jsonFull = JSON.parse(s);
    v_DamageLog = jsonFull["DamageLog"];

    v_FacilitySpecId =v_DamageLog["FacilitySpecId"];
    v_InspectionId = v_constGUIDEmpty;
    v_DamageLogId = v_DamageLog["DamageLogId"];

    var __s = v_DamageLog["LineNumber"];
    v_lineNumber = parseInt(__s.toString());
    v_SerialNumber = v_DamageLog["SerialNumber"];
    var FacilityType = v_DamageLog["FacilityType"];
    v_ImagesCur = jsonFull["Images"];

    var s = android.getSpecialNote();
    var jsonSpecialNoteFull = JSON.parse(s);
    if (0 <= FacilityType.indexOf("照明"))
    {
        v_SpecialNote = jsonSpecialNoteFull["categoriesLight"];
    }
    else
    {
        v_SpecialNote = jsonSpecialNoteFull["categories"];
    }

    setDropDown($("#Note1List"), v_SpecialNote[0].items, v_DamageLog["Note1"]);
    setDropDown($("#Note2"), v_SpecialNote[1].items, v_DamageLog["Note2"]);
    setDropDown($("#Note3"), v_SpecialNote[2].items, v_DamageLog["Note3"]);
    setDropDown($("#Note4"), v_SpecialNote[3].items, v_DamageLog["Note4"]);

    setDropDown($("#InspectionNote"), v_SpecialNote[4].items, v_DamageLog["InspectionNote"]);
    setDropDown($("#NoInspectedCause"), v_SpecialNote[5].items, v_DamageLog["NoInspectedCause"]);
    setDropDown($("#InspectionPlan"), v_SpecialNote[6].items, v_DamageLog["InspectionPlan"]);
    setDropDown($("#InspectionManner"), v_SpecialNote[7].items, v_DamageLog["InspectionManner"]);



        $(".InspectionData").each(function () {
            var dtype = $(this).attr("dataType");
            var id = $(this).attr("id");
            var v = v_DamageLog[id];
            if (null == v)
                v = "";
            if (dtype == "text") {
                $(this).text(v);
            }
            else if (dtype == "val") {
                $(this).val(v);
            }
        });


}


function setDropDown(oDropdown, oList, val )
{
    if (null == val || 'null' == val)
    {
        val = "";
    }
    else
    {
        if(val != ""){
            var fExist = false;
            $.each(oList, function (i, v) {
                var _v = oList[i].textValue;
                if (_v == val)
                {
                    fExist = true;
                }
            });
            if (!fExist)
            {
                $option = $('<option>')
                    .attr('value', val)//.val(val)
                    .text(val);
                $(oDropdown).append($option);
            }
        }
    }
//    $.each(oList, function (i, v) {
//        $option = $('<option>')
//            .val(oList[i].textValue)
//            .text(oList[i].textValue);
//        $(oDropdown).append($option);
//    });

    $.each(oList, function (i, v) {
        $option = $('<option>')
            .attr('value', oList[i].textValue)
            .text(oList[i].textValue);
        $(oDropdown).append($option);
    });

}



function showImages() {
    var oImages = v_ImagesCur;
    var nImages = oImages.length;
    var path = "";

    $(".DamageLogImgInfo").each(function (index, element) {
        var _SelectedStatus = $(this).attr("SelectedStatus");
        for(var i = 0 ; i < nImages; i++)
        {
            if (oImages[i].SelectedStatus == _SelectedStatus)
            {
                $(this).find(".DamageLogImgCaption").val(oImages[i].Caption);
                path = "file:///" + v_dataFolderPath + "/Images/" + v_SerialNumber + "/" + oImages[i].fileName;
                $(this).find(".DamageLogImg").attr('src', path);
            }
        }
    });
}



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
    saveData();
    android.EndInspectionDetail(v_lineNumber);
    v_fEditMode = false;
    android.go_ar();
}

function GoFacility() {
    saveData();
    v_fEditMode = false;
    android.EndInspectionDetail(v_lineNumber);
    //	android.go_InspectionFromFacility();
    android.go_Facirity();

    location.href = "facility.html";
}
function GoInspection() {
    saveData();
    v_fEditMode = false;
    android.EndInspectionDetail(v_lineNumber);
    android.go_InspectionFromFacility();

    // App-Improve 41
    if(v_lineNumber > 11)
        location.href = "Inspection.html#line" + (v_lineNumber - 5);
    else
        location.href = "Inspection.html";
}
function StartEdit() {
    android.StartInspectionDetail(v_lineNumber);
    EditModeUI(true);

}

function EndEdit() {
    saveData();
    android.EndInspectionDetail(v_lineNumber);
    EditModeUI(false);
}


function saveData()
{
    if(v_fEdited)
    {
        var fSave = true;
        var jsonData = {};
        var DamageLog = {};
        var Images = {
            Images: []
        };
        $(".InspectionData").each(function () {
            var field = $(this).attr("id");
            var dataType = $(this).attr("dataType");
            if (dataType == "val")
            {
                var v = $(this).val();
                DamageLog[field] = v;
            }
        });
        jsonData["DamageLog"] = DamageLog;
        $(".DamageLogImgInfo").each(function () {
            var jsonItem = {};
            var SelectedStatus = $(this).attr("SelectedStatus");
            jsonItem["SelectedStatus"] = SelectedStatus;

            var DamageLogImgCaption = $(this).find(".DamageLogImgCaption").val();
            jsonItem["DamageLogImgCaption"] = DamageLogImgCaption;
            Images.Images.push(jsonItem);
        });
        jsonData["Images"] = Images;
        var s = JSON.stringify(jsonData);
        android.saveDamageLogData(s, fSave, v_fEdited);
    }
    v_fEdited = false;

}

var _ImgBox = "<div id={idImg} class=\"col-xs-3 imgSelectorItem\" ImageFileId={ImageFileId}><img src=\"{ImagePath}\" class=\"img-responsive center-block\" /></div>";
var _ImgBoxNoImg = "<div id=\"idImg00000000-0000-0000-0000-000000000000\" class=\"col-xs-3 imgSelectorItem\" ImageFileId=00000000-0000-0000-0000-000000000000><img src=\"images/NoImg.jpg\" class=\"img-responsive center-block\" /></div>";
var v_ImgSelectorSelectedId = null;
var v_ImgSelectorSelectedSrc = null;

function ShowImgSelector()
{
    var s = android.getDamageLogImages();
    var jo = JSON.parse(s);
    var SerialNumber = jo["SerialNumber"];
    var oImages = jo["Images"];
    var nImages = oImages.length;
    var path = "";

    var oImageArea = $("#idImgItems");
    $(oImageArea).empty();
    v_ImgSelectorSelectedId = null;
    v_ImgSelectorSelectedSrc = null;

    for(var i = 0 ; i < nImages; i++)
    {
        var _SelectedStatus = oImages[i].SelectedStatus;
        if (0 == _SelectedStatus)
        {
            path = "file:///" + v_dataFolderPath + "/Images/" +  SerialNumber + "/" + oImages[i].fileName;
            var ImgBox = _ImgBox.replace("{ImageFileId}", oImages[i].ImageFileId.toString());
            ImgBox = ImgBox.replace("{idImg}", "idImg" + oImages[i].ImageFileId.toString());
            ImgBox = ImgBox.replace("{ImagePath}", path);
            $(oImageArea).append(ImgBox);
        }
    }
    $(oImageArea).append(_ImgBoxNoImg);
    disabled($("#pBtn_OK"), true);

    $(".imgSelectorItem").click(function () {
        if (null != v_ImgSelectorSelectedId)
        {
            var _idOld = "#"+v_ImgSelectorSelectedId;
            $(_idOld).css("background-color",bgNormal);
        }
        v_ImgSelectorSelectedId = $(this).attr("id");
        v_ImgSelectorSelectedSrc = $(this).find("img").attr("src");
        var _id = "#"+ v_ImgSelectorSelectedId;
        $(this).css("background-color",bgEditMode);
        disabled($("#pBtn_OK"), false);
    });


    $("#idImgSelectPopup").modal('show');
}

function setImage()
{
    var _id =  "#"+v_ImgSelectorSelectedId;
    var oSelected = $(_id);
    var ImageFileId = $(oSelected).attr("ImageFileId");
    var s = android.changeSelectedImgDamageLof(ImageFileId, v_SelectedStatus);

    $(".DamageLogImgInfo").each(function(index, element)
    {
        var SelectedStatus = $(this).attr("SelectedStatus").toString();
        if (SelectedStatus == v_SelectedStatus)
        {
            $(this).find(".DamageLogImg").attr('src', v_ImgSelectorSelectedSrc);
        }
    });
    $("#idImgSelectPopup").modal('hide');

}

function AppendDeviceLog(Action, TimeStampType)
{
    android.appendDeviceLog(v_FacilitySpecId, v_InspectionId, v_DamageLogId, v_lineNumber, Action, TimeStampType);
}
