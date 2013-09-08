route = null
game = null
opponent = null
chatSocket = null

areFriend = (p1,p2) -> ((p1.hasClass("blackp") && p2.hasClass("blackp")) || ((p1.hasClass("whitep")) && (p2.hasClass("whitep"))))

areEnemy = (p1,p2) -> ((p1.hasClass("blackp") && p2.hasClass("whitep")) || ((p1.hasClass("whitep")) && (p2.hasClass("blackp"))))

setDraggables = ->
	$( ".case > .draggable" ).draggable({ grid: [ 50, 50 ], revert: "invalid", zIndex : 3000 })
	$(".deadz > .draggable").draggable({revert:"invalid"})			
	#alert($(".deadz > span")[0].attr("id"))

setDroppables = ->
	$( ".droppable" ).droppable({
		accept: (drag) -> !areFriend( $( this ).children("span") , drag )
		,
		drop: (event,ui) ->
			#$( this ).effect("transfer", {to: "#blackdead", className: "ui-effects-transfer" }, 500, callback) TODO transfer
			dead = false
			dropp = $(this).children("span")
			if(areEnemy(dropp, ui.draggable))
				if(!opponent)
					alert "remove"+dropp.attr("id")
					dead = dropp.attr("id")
					dropp.remove()
				else
					if(dropp.hasClass("blackp"))
						dropp.appendTo("#blackpdead")
					else
						dropp.appendTo("#whitepdead")
			ui.draggable.appendTo($(this))
			ui.draggable.css({"left" : "0px","right" : "0px","top" : "0px","bottom" : "0px"})
			
			board = stringifyBoard()
			gameName = game
			saveGame(gameName, board)
			data = {"game" : gameName, "board" : board}
			if(dead) then data.dead = dead
			#send last dead if there is a dead & game mode = blitz aka there is an opponent		
			setDraggables()
			sendMessage(JSON.stringify(data))
	})
	$( ".deadz" ).droppable({})

	
stringifyBoard = ->
	gameStr = ""
	empty = 0
	(
		empty = 0
		gameStr+='\\'
		(
			piece = $("#"+i+"-"+j).children("span")					
			if( piece.attr("id") )
				if(empty>0)
					gameStr+=empty
					empty = 0
				gameStr += piece.attr("id")
						
			else empty++
		) for j in [1..8]
		if(empty>0) then gameStr += empty
	) for i in [1..8]

	#deadz	
	alldeadz = $(".deadz").children("span")			
	deadzString = ""
	if(alldeadz.length)
		(deadzString += alldeadz[i].id) for i in [0..alldeadz.length-1]
	
	gameStr += " " + deadzString
	gameStr.substring(1,gameStr.length)


saveGame = (board) -> setCurrentBoard(board)

loadGame = (boardStr) ->
	$("span").remove()
	board = boardStr.split(' ')
	lines = board[0].split('\\')
	deadz = board[1]
	
	#vivants
	(
		trueJ = 1
		(
			chara = lines[i][j]
			if(!isNaN(chara * 1))
				trueJ += chara * 1 
			else		
				#span = '<span id="'+chara+'" class="draggable '+(chara == chara.toLowerCase() ? 'blackp' : 'whitep')+'">'
				span = getSpanPiece(chara,if (chara == chara.toLowerCase()) then 'blackp' else 'whitep')
				#span += pps[chara.toUpperCase()]+'</span> '
				$("#"+(i+1)+"-"+trueJ).append(span)
				trueJ++
		) for j in [0..lines[i].length-1]
	) for i in [0..7]
		
	#deadz
	(
		if(p.toLowerCase() == p)
			$("#blackpdead").append(getSpanPiece(p,"blackp"))
		else
			$("#whitepdead").append(getSpanPiece(p,"whitep"))
	) for p in deadz
	
	setDraggables()

		
getSpanPiece = (id,clazz) ->
	span = '<span id="'+id+'" class="draggable '+clazz+'"> '
	span += pps[id.toUpperCase()]+' </span>'
	span

	
sendMessage = (msg) -> chatSocket.send(msg); alert "SENT"

receiveEvent = (event) ->
	alert "EVENT !"
	data = JSON.parse(event.data)
	if(data.board) then setCurrentBoard(data.board)
	if(data.help) then setCurrentBoard(getCurrentBoard()+data.help) #space problems
	loadGame(getCurrentBoard())
			
getCurrentBoard = -> window.localStorage[game]

setCurrentBoard = (board) -> window.localStorage[game] = board

init = (r, g, o) ->
	[route, game, opponent] = [r,g,o]
	#'T' -> ("\u2656","\u265C"), 'C' -> ("\u2658","\u265E"), 'F' -> ("\u2657","\u265D"), 'D' -> ("\u2655","\u265B"), 'R' -> ("\u2654","\u265A")))
	WS = if(window['MozWebSocket']) then MozWebSocket else WebSocket
	chatSocket = new WebSocket(route)
	if(getCurrentBoard()) then loadGame(getCurrentBoard())
	else saveGame(stringifyBoard())
	
	setDraggables()
	setDroppables()
	
	chatSocket.onmessage = receiveEvent
