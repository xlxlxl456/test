
$(function () {

    // completionList
    $(".complationList").click(function () {
        loatHtml(1);
    });

    // 現在時刻を表示
    setInterval('showClock()', 1000);
});


// 画面遷移
function loatHtml(num) {
    console.log("loadHtml");
    if (num == 1) {
        window.webkit.messageHandlers.loadHtml.postMessage("workList");
    }
}


// 現在時刻を取得
function getClock() {
    var now = new Date();
    var str =
        now.getFullYear() + ":" +
        set2fig(now.getMonth() + 1) + ":" +
        set2fig(now.getDate()) + " " +
        set2fig(now.getHours()) + ":" +
        set2fig(now.getMinutes()) + ":" +
        set2fig(now.getSeconds());
    return str;
}

// 現在時刻を表示
function showClock() {
    var now = new Date();
    $("#currentTime").html(
        now.getFullYear() + "/" +
        set2fig(now.getMonth() + 1) + "/" +
        set2fig(now.getDate()) + " " +
        set2fig(now.getHours()) + ":" +
        set2fig(now.getMinutes()) + ":" +
        set2fig(now.getSeconds()));
}

// 桁数が1桁だったら先頭に0を加えて2桁に調整する
function set2fig(num) {
    var ret;
    if( num < 10 ) { ret = "0" + num; }
    else { ret = num; }
    return ret;
}
