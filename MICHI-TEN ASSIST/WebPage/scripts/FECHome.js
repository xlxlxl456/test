
$(function () {
    adjustPosition();
    $("#btnLogin").click(function () {
        login();
    });
    $("#LoginName").focus();

});

$(window).on('load resize', function () {
    adjustPosition();
});

function adjustPosition() {

    var h = $("#idLoginElm").innerHeight();
    if (10 < h)
    {
        $("#btnLogin").height(h * 2);
    }
    return;

    var hTotal = $(window).height();
    var hContent = $("#idLoginContent").outerHeight();
    var mt = (hTotal - hContent) / 3;
    if (mt < 0)
        mt = 0;
    $("#idLoginContent").css("margin-top", mt.toString() + "px");

}

function login()
{
    var userId = $("#LoginName").val();
    var pw = $("#Password").val();
    var s = android.login(userId, pw);
    if (null != s && 0 < s.length)
    {
        $("#idLoginError").text("ユーザーIDまたは、パスワードが正しくありません");
    }
    else
    {
    	android.go_ar();
    }
}
