
var bgNormal = "#FFFFFF";
var bgEditMode = "#CEECF5";
var bgChangedItem = "#ffc0cb";

var oChangedList = [];

var v_FacilitySpecId = "";
var v_InspectionId = "";
var v_DamageLogId = "";
var v_LineNumber = -1;

var v_TimeStampType_Log = 0;
var v_TimeStampType_Start = 1;
var v_TimeStampType_End = 2;


var v_fEdited = false;
var v_fEditMode = false;

var v_dataFolderPath = null;

var v_SelectedStatus = 0;


var FacilityTypes = [
'道路標識',
'道路情報提供装置',
'道路情報提供措置(添架物有)',
'道路照明施設',
'その他'
];
var RoadTypes = [
'高速自動車国道',
'一般国道(指定区間内 高規格)',
'一般国道(指定区間内 高規格以外)',
'一般国道(指定区間外)',
'都道府県道',
'市町村道',
'その他'
];

var StanchionTypes = [
'路側式',
'片持式(逆Ｌ型)',
'片持式(Ｆ型)',
'片持式(テーパーポール型)',
'片持式(Ｔ型)',
'門形式(オーバーヘッド型)',
'添架式',
'その他'
];
var StanchionTypesLight = [
'ポール照明方式(テーパーポール型)',
'ポール照明方式(直線型)',
'ポール照明方式(Ｙ型)',
'添架式',
'トンネル照明',
'その他'
];
var SurfaceTypes = [
'塗装式',
'亜鉛めっき式',
'塗装式＋亜鉛めっき式',
'その他'
];
var BaseTypes = [
'埋め込み型',
'ベースプレート型',
'添架型',
'その他'
];

var StanchionLibTypes = [
'三角リブ',
'Ｕ字リブ',
'その他',
'無'
];
var RoadEdgeConditions = [
'コンクリート',
'アスファルト',
'土砂',
'ベースプレート露出',
'インターロッキング',
'その他'
];
var LightningTypes = [
'水銀灯',
'ナトリウム灯',
'蛍光灯',
'ＬＥＤ',
'その他'
];
var SignAttachmentTypes = [
'固定式',
'吊下式',
'その他'
];
var SignFallSolveds = [
'有(全部)',
'有(一部)',
'今回実施(全部)',
'今回実施(一部)',
'無'
];
var LoosenSolveds = [
'有(全部)',
'有(一部)',
'今回実施(全部)',
'今回実施(一部)',
'無'
];
var MatchedMarkings = [
'有(全部)',
'有(一部)',
'今回実施(全部)',
'今回実施(一部)',
'無'
];
var VibrationDumpers = [
'有',
'今回実施',
'無'
];
var DrainageImproveds = [
'有',
'今回実施',
'無',
'当該無し'
];
var PlaceEnvironments = [
'一般部',
'橋梁部',
'トンネル',
'横断歩道橋',
'その他'
];
var DistanceFromSeas = [
'100m 未満',
'100m～ 1km 未満',
'1km～ 5km 未満',
'5km～20km 未満',
'20km 以上'
];
var SnowAreas = [
'該当する',
'該当しない'
];
var WindAreas = [
'該当する',
'該当しない'
];
var SnowRemoveAreas = [
'該当する',
'該当しない'
];
var EmergencyRoads = [
'一次',
'二次',
'三次',
'無'
];
var SchoolRoads = [
'有',
'無'
];
var InspectionTypes = [
'初期点検',
'定期点検(詳細)',
'定期点検(中間)',
'異常時点検',
'特定の点検計画に基づく点検'
];
var InspectionManners = [
'近接目視',
'近接目視＋非破壊検査',
'外観目視',
'その他'
];
var RenewalLogs = [
'有',
'無',
'不明'
];


var v_fAlreadyGoOutside = false;


$(function () {
    loadCurrentFacilityData();

    showFacilityMap();
    showFacilityImages();
    initPage();

    showCorrection();

    $("#btnGoAR").click(function () {
        if (!v_fAlreadyGoOutside)
        {
            v_fAlreadyGoOutside = true;
            disabled($("#btnGoAR"), true);

            android.setEditMode(false);
            AppendDeviceLog("Facility End Go AR", v_TimeStampType_End);
            GoAR();
        }
    });
    $("#btnGoInspection").click(function () {
        if (!v_fAlreadyGoOutside)
        {
            v_fAlreadyGoOutside = true;
            disabled($("#btnGoInspection"), true);
            android.setEditMode(false);
            AppendDeviceLog("Facility End Go Inspection", v_TimeStampType_End);
            GoInspection();
        }
    });
    $("#btnEditStart").click(function () {
        StartEdit();
    });
    $("#btnEditEnd").click(function () {
        if(!v_fEdited)
        {
            //android.EndEditFacility();
            android.SaveEditFacility();
        }
        EndEdit();
        android.setEditMode(false);
    });
    $("#btnCompleteInspection").click(function () {

        if (!confirm('点検年月日が更新されますが、よろしいですか？')) {
            return;
        }


        if (!v_fAlreadyGoOutside)
        {
            v_fAlreadyGoOutside = true;
            disabled($("#btnCompleteInspection"), true);
            AppendDeviceLog("Facility End Complete", v_TimeStampType_End);
            completeInspection();
            android.setEditMode(false);
        }
    });
    $("#btnChangeLocation").click(function () {
        $("#btnGoAR").prop("disabled", true);
        $("#btnGoInspection").prop("disabled", true);
        $("#btnCompleteInspection").prop("disabled", true);

        var no = $('#SerialNumber').val();
        android.changeLocationFromFacility(/*no*/);
    });
    $(".FacilityData").change(function () {
        oChangedList.push(this);
        $(this).css("background-color",bgChangedItem);
        v_fEdited = true;
    });
    $(".FacilityImgCaption").change(function () {
        oChangedList.push(this);
        $(this).css("background-color",bgChangedItem);
        v_fEdited = true;
    });

    $(".btnSelectImg").click(function () {
        v_SelectedStatus = $(this).attr("SelectedStatus");
        ShowImgSelector();
    });


    $(".FacilityImg").click(function () {
        android.setEditMode(v_fEditMode);
        if (v_fEditMode)
        {
            if (!v_fAlreadyGoOutside)
            {
                v_fAlreadyGoOutside = true;
                saveFacilityData();
                var SelectedStatus = $(this).attr("SelectedStatus");
                android.goto_camera_mode_byFacility(SelectedStatus);
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
        AppendDeviceLog("Facility Start", v_TimeStampType_Start);
    }
});


function initPage()
{
    var h = $("#idTop").outerHeight();
    $("#idScrollContent").css("margin-top", h.toString() + "px");
    v_fEdited = false;
    v_fEditMode = false;
    disabledControls(true);
    disabled($("#btnEditEnd"), true);
    $("#idDebug").text(h);

}


function showCorrection()
{
    var val = android.showCorrection();
    $("#correction").html("補正秒数 " + val + " 秒");
}


function loadCurrentFacilityData()
{
    v_dataFolderPath = android.getDataFolder();

    var s = android.getFacilityData();
    var jsonFacility = JSON.parse(s);

    v_FacilitySpecId =jsonFacility["FacilitySpecId"];
    v_InspectionId = v_constGUIDEmpty;
    v_DamageLogId = v_constGUIDEmpty;
    v_LineNumber = -1;

    var facilityType =jsonFacility["FacilityType"];
    setDropDown($("#FacilityType"), FacilityTypes, facilityType);
    setDropDown($("#RoadType"), RoadTypes, jsonFacility["RoadType"]);

    var stanchionType =jsonFacility["StanchionType"];
    if (0 <= facilityType.indexOf("照明"))
    {
        setDropDown($("#StanchionType"), StanchionTypesLight, stanchionType);
    }
    else
    {
        setDropDown($("#StanchionType"), StanchionTypes, stanchionType);
    }
    setDropDown($("#SurfaceType"), SurfaceTypes, jsonFacility["SurfaceType"]);
    setDropDown($("#BaseType"), BaseTypes, jsonFacility["BaseType"]);
    setDropDown($("#StanchionLibType"), StanchionLibTypes, jsonFacility["StanchionLibType"]);
    setDropDown($("#RoadEdgeCondition"), RoadEdgeConditions, jsonFacility["RoadEdgeCondition"]);
    setDropDown($("#LightningType"), LightningTypes, jsonFacility["LightningType"]);
    setDropDown($("#SignAttachmentType"), LightningTypes, jsonFacility["SignAttachmentType"]);

    setDropDown($("#SignFallSolved"), SignFallSolveds, jsonFacility["SignFallSolved"]);
    setDropDown($("#LoosenSolved"), LoosenSolveds, jsonFacility["LoosenSolved"]);
    setDropDown($("#MatchedMarking"), MatchedMarkings, jsonFacility["MatchedMarking"]);
    setDropDown($("#VibrationDumper"), VibrationDumpers, jsonFacility["VibrationDumper"]);
    setDropDown($("#DrainageImproved"), DrainageImproveds, jsonFacility["DrainageImproved"]);
    setDropDown($("#PlaceEnvironment"), PlaceEnvironments, jsonFacility["PlaceEnvironment"]);
    setDropDown($("#DistanceFromSea"), DistanceFromSeas, jsonFacility["DistanceFromSea"]);
    setDropDown($("#SnowArea"), SnowAreas, jsonFacility["SnowArea"]);
    setDropDown($("#WindArea"), WindAreas, jsonFacility["WindArea"]);
    setDropDown($("#SnowRemoveArea"), SnowRemoveAreas, jsonFacility["SnowRemoveArea"]);
    setDropDown($("#EmergencyRoad"), EmergencyRoads, jsonFacility["EmergencyRoad"]);
    setDropDown($("#SchoolRoad"), SchoolRoads, jsonFacility["SchoolRoad"]);
    setDropDown($("#InspectionType"), InspectionTypes, jsonFacility["InspectionType"]);
    setDropDown($("#InspectionManner"), InspectionManners, jsonFacility["InspectionManner"]);
    setDropDown($("#RenewalLog"), RenewalLogs, jsonFacility["RenewalLog"]);

    Object.keys(jsonFacility).forEach(function (key) {
        var id = "#" + key;
        var o = $(id);
        if (0 < o.length)
        {
            var v = jsonFacility[key];
            if (null == v)
                v = "";
            $(o).val(v);
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
        var fExist = false;
        $.each(oList, function (i, v) {
            if (v == val)
            {
                fExist = true;
            }
        });
        if (!fExist)
        {
            $option = $('<option>')
                .val(val)
                .text(val);
            $(oDropdown).append($option);
        }
    }
    $.each(oList, function (i, v) {
        $option = $('<option>')
            .val(v)
            .text(v);
        $(oDropdown).append($option);
    });

}


function showFacilityMap()
{
    var s = android.getFacilityMap();
    if (0 < s.length)
    {
        var jo = JSON.parse(s);
        var SerialNumber = jo["SerialNumber"];
        var fileName = jo["fileName"];
        if (0 < fileName.length)
        {
            var path = "file:///" + v_dataFolderPath + "/Images/" +  SerialNumber + "/" + fileName;
            $("#FacilityMap").attr('src', path);
        }

    }

}

function showFacilityImages()
{
    var s = android.getFacilityImages();
    if ( 0 < s.length)
    {
        var jo = JSON.parse(s);
        var SerialNumber = jo["SerialNumber"];
        var oImages = jo["Images"];
        var nImages = oImages.length;
        var path = "";

        $(".FacilityImgInfo").each(function(index, element)
        {
            var SelectedStatus = $(this).attr("SelectedStatus");
            for(var i = 0 ; i < nImages; i++)
            {
                var _SelectedStatus = oImages[i].SelectedStatus;
                if (_SelectedStatus == SelectedStatus)
                {
                    $(this).find(".FacilityImgCaption").val(oImages[i].Caption);
                    path = "file:///" + v_dataFolderPath + "/Images/" +  SerialNumber + "/" + oImages[i].fileName;
                    $(this).find(".FacilityImg").attr('src', path);
                }
            }
        });
    }
}


function saveFacilityData()
{
    if (v_fEdited)
    {
        var jsonData = {};
        var Facility = {};
        var Images = {
            Images: []
        };

        $(".FacilityData").each(function () {
            var field = $(this).attr("id");
            var v = $(this).val();
            Facility[field] = v;
        });
        Facility["SerialNumber"] = $("#SerialNumber").val()
        jsonData["Facility"] = Facility;
        $(".FacilityImgInfo").each(function () {
            var jsonItem = {};
            var SelectedStatus = $(this).attr("SelectedStatus");
            jsonItem["SelectedStatus"] = SelectedStatus;

            var ImgCaption = $(this).find(".FacilityImgCaption").val();
            jsonItem["ImgCaption"] = ImgCaption;
            Images.Images.push(jsonItem);
        });
        jsonData["Images"] = Images;
        var s = JSON.stringify(jsonData);
        android.savetFacilityData(s);
        v_fEdited = false;
    }

}

function disabledControls(f)
{
    disabled($(".FacilityData"), f);
    disabled($(".FacilityImgCaption"), f);
    disabled($(".btnSelectImg"), f);
}

function setBgColor(fEditMode)
{
    if (fEditMode)
    {
       $(".FacilityData").css("background-color",bgEditMode);
       $(".FacilityImgCaption").css("background-color",bgEditMode);
    }
    else
    {
       $(".FacilityData").css("background-color",bgNormal);
       $(".FacilityImgCaption").css("background-color",bgNormal);
    }

    $.each(oChangedList , function (i, v) {
        var o = oChangedList[i];
       $(o).css("background-color",bgChangedItem);
    });



}


function EditModeUI(fEditMode)
{
    if (fEditMode)
    {
        v_fEditMode = true;
        disabledControls(false);
        disabled($("#btnEditStart"), true);
        disabled($("#btnEditEnd"), false);
    }
    else
    {
        v_fEditMode = false;
        disabledControls(true);
        disabled($("#btnEditStart"), false);
        disabled($("#btnEditEnd"), true);
    }
    setBgColor(fEditMode);
}


function GoAR()
{
    saveFacilityData();
    v_fEditMode = false;
	android.go_ar();
}

function GoInspection()
{
    saveFacilityData();
    v_fEditMode = false;
	android.go_InspectionFromFacility();
    location.href = "Inspection.html";

}

function StartEdit()
{
	android.StartEditFacility();
    EditModeUI(true);
}

function EndEdit()
{
   saveFacilityData();
   v_fEditMode = false;
   EditModeUI(false);

}

var _ImgBox = "<div id={idImg} class=\"col-xs-3 imgSelectorItem\" ImageFileId={ImageFileId}><img src=\"{ImagePath}\" class=\"img-responsive center-block\" /></div>";
var _ImgBoxNoImg = "<div id=\"idImg00000000-0000-0000-0000-000000000000\" class=\"col-xs-3 imgSelectorItem\" ImageFileId=00000000-0000-0000-0000-000000000000><img src=\"images/NoImg.jpg\" class=\"img-responsive center-block\" /></div>";
var v_ImgSelectorSelectedId = null;
var v_ImgSelectorSelectedSrc = null;

function ShowImgSelector()
{
    var nImages = 0;
    var path = "";
    var s = android.getFacilityImages();
    var SerialNumber = "";
    var oImageArea = $("#idImgItems");
    $(oImageArea).empty();
    v_ImgSelectorSelectedId = null;
    v_ImgSelectorSelectedSrc = null;
    if ( 0 < s.length)
    {
        var jo = JSON.parse(s);
        SerialNumber = jo["SerialNumber"];
        oImages = jo["Images"];
        nImages = oImages.length;
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
    var s = android.changeSelectedImgFacility(ImageFileId, v_SelectedStatus);

    $(".FacilityImgInfo").each(function(index, element)
    {
        var SelectedStatus = $(this).attr("SelectedStatus").toString();
        if (SelectedStatus == v_SelectedStatus)
        {
            $(this).find(".FacilityImg").attr('src', v_ImgSelectorSelectedSrc);
        }
    });
    $("#idImgSelectPopup").modal('hide');

}



function completeInspection()
{
    if(!v_fEdited)
    {
        android.EndEditFacility();
    }
    EndEdit();
    android.fix_from_shogen();
}

function AppendDeviceLog(Action, TimeStampType)
{
    android.appendDeviceLog(v_FacilitySpecId, v_InspectionId, v_DamageLogId, v_LineNumber, Action, TimeStampType);
}


function finishChangeLocationButton(){
    $("#btnGoAR").prop("disabled", false);
    $("#btnGoInspection").prop("disabled", false);
    $("#btnCompleteInspection").prop("disabled", false);
}

function finishChangeLocationLatLng(str){
    var strs = str.split(',');
    $("#Latitude60").val(strs[0]);
    $("#Longitude60").val(strs[1]);
}


