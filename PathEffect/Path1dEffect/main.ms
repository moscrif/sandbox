
var app = new Moscrif.Window();

var circle = new Path();
circle.addCircle(0, 0, 3);

var paint = new Paint();
paint.style = #stroke;
paint.textSize = 80;
paint.color = 0xff0000ff;

var p = new Paint();
p.color = 0xff00ff00;
p.style = #stroke;
p.pathEffect = PathEffect.effect1d(circle, 10, 10, #morph);
var rasterizer = new LayerRasterizer();
rasterizer.add(p);
paint.rasterizer = rasterizer;

app.onDraw = function(s, c)
{
    c.clear(0xffffffff);
    c.drawText("Path 1d effect", 10, 100, paint);
    c.drawRect(100, 500, 300, 300, paint);
    c.drawCircle(300, 600, 100, paint);
}

app.onProcess = function(s)
{
    return app.quit ? 0 : 1;
}

app.onPointerPressed = function(s, k)
{
    app.quit = true;
}

app.init().run();