var $ = require("../node_modules/jquery/dist/jquery.min.js");

function createLink(href, text) {
	let $link = $("<div>");
	$link.addClass("link linkActive");
	$link.data("href", href);
	$link.attr("unselectable", "on")
	$link.text(text);
	return $link;
}

function link_onClick(event) {
	event.preventDefault();
	let href = $(this).data("href")
	if (href) {
		href = window.byondSrc + href;
		window.location.href = href;
	}
}

module.exports.parseCurrentPage = function () {
	$("listBoat").each(function () {
		var config_attr = $(this).data("config");
		if (!config_attr)
			return;

		let th = $(this).data("header");

		let dataList = config[config_attr];
		$(this).replaceWith("<table class=\"listBoat\" id=\"WORK\">");

		if (th) {
			let assembledString = "<tr>";
			let split = th.split("|");
			for (let header in split) {
				assembledString += "<th>";
				assembledString += split[header];
				assembledString += "</th>";
			}
			assembledString += "</tr>";
			$("#WORK").append(assembledString);
		}

		for (let key in dataList) {
			let value = dataList[key];
			let $tr = $("<tr>");
			$tr.append("<td>"+key+"</td>");
			$tr.append("<td>"+value+"</td>");
			let $td = $("<td>");
			$td.append(createLink('table='+config_attr+';delete_row='+key, "X"))
			$tr.append($td);
			$("#WORK").append($tr);
		}

		$(createLink('table='+config_attr+';create_row=1', "New")).insertAfter("#WORK").click(link_onClick);
		$("#WORK .link").click(link_onClick);
		$("#WORK").attr("id", null);
	});

	$("activeLink").each(function () {
		let href = $(this).data("href");
		let config_attr = $(this).data("config");
		let internalText = $(this).text();

		$(this).replaceWith("<div id=\"WORK\">")
		$("#WORK")
			.addClass("link linkActive")
			.data("href", href)
			.text(internalText)
			.on("click", link_onClick)
			.attr("unselectable", "on")
		
		if (config_attr) {
			if (window.config[config_attr]) {
				$("#WORK")
					.addClass("linkOn")
					.text("Enabled")
			} else {
				$("#WORK")
					.addClass("linkOff")
					.text("Disabled")
			}
		}

		$("#WORK").attr("id", null);
	});
	


	$("configRead").each(function () {
		let seeked = $(this).data("config");
		$(this).replaceWith("<span id=\"WORK\">")
		$("#WORK")
			.text(window.config[seeked])
			.attr("id", null);
	});
}