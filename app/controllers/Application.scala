package controllers

import play.api._
import play.api.mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.libs.iteratee._
import play.api.libs.json._

object Application extends Controller {
  
  val helloForm = Form(
	"game" -> nonEmptyText
  )
  
  def index(game : String, opp : Option[String]) = Action { implicit request =>
    Ok(views.html.index(game, opp))
  }
  
	def normal(game: String) = Action { implicit request =>
		Ok(views.html.index(game,None))
	}
	
	def blitz(game: String, opp : String) = Action { implicit request => 
		Ok(views.html.index(game,Some(opp)))
	}
	
  def hello = Action { Ok(views.html.hello(helloForm)) }
  
  def createGame = Action { implicit request =>
		val game = helloForm.bindFromRequest.get
		Ok(views.html.index(game,None))
  }
  
  
  var players = List[(String,(Enumerator[JsValue],Concurrent.Channel[JsValue]))]()
  var blitzz = List[(String,String)]()
  
  def joinGame(game : String, game2 : Option[String]) = WebSocket.using[JsValue] { implicit request =>
		 // Log events to the console
		  val in = Iteratee.foreach[JsValue]{ msg =>
				println(msg)
				val currgame = (msg \ "game").as[String]
				(msg \ "dead").asOpt[String] match {
					case Some(dead) => {
						val duo = blitzz find { tables  => tables._1 == currgame || tables._2 == currgame }
						//si dead est envoye, duo ne peut pas etre None. TODO Refactor
						val otherTable = if(duo.get._1 == currgame) duo.get._2 else duo.get._1

						players.find ( _._1 == otherTable ) match {
							case Some(table) => table._2._2.push(
								JsObject(
									Seq(
									"help" -> JsString(dead)
									)
								))
							case None => println("Can't play blitz by yourself")
						}
					}
					
					case None => println("pas de mort")
				}
				println(currgame)
				for(p <- players) println(p._1)
				for(p <- players if p._1 == currgame ) {println(msg); p._2._2 push msg}
		  }.mapDone { _ =>
				println("Disconnected")
		  }
	
		  // Send a single 'Hello!' message
		  players = (game, Concurrent.broadcast[JsValue]) +: players
			game2 foreach { g2 =>
				blitzz = (game,g2) :: blitzz
			}
			
		  (in, players.head._2._1)
  }
	
	def blitzSock(game: String, game2 : String) = WebSocket.using[JsValue] { implicit request =>
			val in = Iteratee.foreach[JsValue]{ msg =>
				val s = (msg \ "game").as[String]
				val board = (msg \ "board").as[String]
				val lastdead = board.split(" ")(1)(0)
				for(p <- players if p._1 == s ) {println(msg); p._2._2 push msg}
		  }.mapDone { _ =>
				println("Disconnected")
		  }

			players = (game, Concurrent.broadcast[JsValue]) +: players
			
		  (in, players.head._2._1)
	
	}
  
}
