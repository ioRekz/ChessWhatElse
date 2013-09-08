import sbt._
import Keys._
import play.Project._

object ApplicationBuild extends Build {

    val appName         = "Chess"
    val appVersion      = "1.0-SNAPSHOT"

    val appDependencies = Seq(
	"org.webjars" %% "webjars-play" % "2.1.0-3",
	"org.webjars" % "jquery" % "1.10.2",
	"org.webjars" % "jquery-ui" % "1.10.2-1",
	"org.webjars" % "jquery-ui-themes" % "1.10.0",
	"org.webjars" % "chosen" % "0.9.12"
    )
    
    val main = play.Project(appName, appVersion, appDependencies).settings(
	coffeescriptOptions := Seq("bare")
    )

}
