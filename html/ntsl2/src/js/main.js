var $ = require("../node_modules/jquery/dist/jquery.min.js");
var templater = require("./templater.js")

$(document).ready(function () {
    var current_tab = "home";

    function tab(tabname) {
        console.log(tabname)
        loadtab(tabname);
    }

    function loadtab(tabname) {
        current_tab = tabname;
        $.when($.ajax({
            url: "tab_" + tabname + ".html",
            cache: false,
            dataType: 'html'}))
            .done(function (tabdata) {
                $("#content").html(tabdata);
                templater.parseCurrentPage();
            });
    }

    window.reload_tab = function() {
        loadtab(current_tab)
    }

    loadtab("home");
    $(".navBtn[data-tab='home']").addClass("btnActive");

    $(".navBtn").click(function () {
        $(".navBtn").removeClass("btnActive")
        var toSwitch = $(this).data("tab");
        $(this).addClass("btnActive");
        tab(toSwitch);
    });
});