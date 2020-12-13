$(document).ready(function($) {
    $(".video-card").click(function() {
        window.document.location = $(this).data("href");
    });
});

function onYouTubeIframeAPIReady() {
    var player;
    player = new YT.Player('YouTubeVideoPlayer', {
        videoId: $('#YouTubeVideoPlayer').data('obj'), // YouTube 影片ID
        width: 850, 
        height: 400, 
        playerVars: {
            autoplay: 1, // 在讀取時自動播放影片
            controls: 1, // 在播放器顯示暫停／播放按鈕
            showinfo: 0, // 隱藏影片標題
            modestbranding: 1, // 隱藏YouTube Logo
            loop: 1, // 讓影片循環播放
            fs: 0, // 隱藏全螢幕按鈕
            cc_load_policty: 0, // 隱藏字幕
            iv_load_policy: 3, // 隱藏影片註解
            autohide: 0 },
    });
}

function filterComment(sentiment) {
    var x, i;

    var btnName = (sentiment == "positive") ? "goodBtn" : "badBtn";
    var btn = document.getElementById(btnName);
    var btnActive = btn.classList.contains("deactivate");

    x = document.getElementsByClassName("comment-part");
    for (i = 0; i < x.length; i++) {
        var sentimentInX = x[i].className.indexOf(sentiment) > -1;
        if (sentimentInX && btnActive) removeClass(x[i], "not-show");
        else if (sentimentInX && !btnActive) addClass(x[i], "not-show");
    }
    btnActive ? btn.classList.remove('deactivate') : btn.className += " deactivate";
}

function addClass(element, name) {
    var i, arr1, arr2;
    arr1 = element.className.split(" ");
    console.log(arr1);
    arr2 = name.split(" ");
    console.log(arr2);
    for (i = 0; i < arr2.length; i++) {
      if (arr1.indexOf(arr2[i]) == -1) {element.className += " " + arr2[i];}
    }
}

function removeClass(element, name) {
    var i, arr1, arr2;
    arr1 = element.className.split(" ");
    arr2 = name.split(" ");
    for (i = 0; i < arr2.length; i++) {
      while (arr1.indexOf(arr2[i]) > -1) {
        arr1.splice(arr1.indexOf(arr2[i]), 1);     
      }
    }
    element.className = arr1.join(" ");
}