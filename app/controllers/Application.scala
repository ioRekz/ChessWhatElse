package controllers

import play.api._
import play.api.mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.libs.iteratee._

object Application extends Controller {
  
  val helloForm = Form(
      "game" -> nonEmptyText 
  )
  
  def index(game : String) = Action { implicit request =>
    Ok(views.html.index(game))
  }
  
  def hello = Action { Ok(views.html.hello(helloForm)) }
  
  def createGame = Action { implicit request =>
		val game = helloForm.bindFromRequest.get
		Redirect(routes.Application.index(game))
  }
  
  //val out = Enumerator.imperative[String](onStart = {println("enumerator created")})
  
  def joinGame = WebSocket.using[String] { implicit request =>
		 // Log events to the console
		  val in = Iteratee.foreach[String](println).mapDone { _ =>
			println("Disconnected")
		  }
		  
		  // Send a single 'Hello!' message
		  val out = Enumerator("Hello!")
		  
		  (in, out)
  }
  
}