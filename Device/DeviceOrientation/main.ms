include "lib://core/log.ms"

var app = new Moscrif.Window();

app.onStart = function(sender)
{
    app.quit = false;
    var paint = new Paint();
    paint.color = 0xff000000;
    paint.textSize = 30;
    paint.style = #stroke;
    app.paint = paint;
    // custom property
    app.currentOrientation = undefined;
    // Window's property: http://moscrif.com/userfiles/pages/developer/api/classes/Moscrif.Window.html#property_orientation
    app.orientation = [#portrait, #landscape-left];
}

app.onOrientationChanged = function(sender, orientation)
{
    logI(orientation);
    app.currentOrientation = orientation;
}

app.onProcess = function(sender)
{
    return app.quit ? 0 : 1;
}

app.onDraw = function(sender, canvas)
{
    canvas.clear(0xffffffff);
    canvas.drawText((app.currentOrientation||"undefined").toString(), 100, 100, app.paint);
    canvas.drawRoundRect(10, 10, System.width - 10, System.height - 10, 8, 8, app.paint);

}

app.onPointerReleased = function(sender, x, y)
{
    if (y < 20)
        app.quit = true;
}

app.init().run();