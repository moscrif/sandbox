
var app = new Moscrif.Window();

var paint0 = new Paint();
paint0.style = #stroke;
paint0.textSize = 80;
paint0.color = 0xff0000ff;

var paint1 = new Paint();
paint1.style = #stroke;
paint1.textSize = 80;
paint1.color = 0xff0000ff;
paint1.imageFilter = ImageFilter.blur(10, 10);

var paint2 = new Paint();
paint2.style = #stroke;
paint2.textSize = 80;
paint2.color = 0xff0000ff;
paint2.looper = new BlurDrawLooper(5, 10, 10, 0xff00ffff);

var paint3 = new Paint();
paint3.style = #stroke;
paint3.textSize = 80;
paint3.color = 0xffffffff;
paint3.looper = new BlurDrawLooper(10, 5, -5, 0xff0000ff);

var paint4 = new Paint();
paint4.style = #stroke;
paint4.textSize = 80;
paint4.color = 0xffffffff;
paint4.looper = new BlurDrawLooper(1, 1, 1, 0xff000000);

var paint5 = new Paint();
paint5.style = #stroke;
paint5.textSize = 80;
paint5.color = 0xff0000ff;
paint5.imageFilter = ImageFilter.blur(1, 1);
paint5.looper = new BlurDrawLooper(3, 5, 5, 0xff000000);

app.onDraw = function(s, c)
{
    c.clear(0xffffffff);
    c.drawText("Moscrif SDK", 10, 100, paint0);
    c.drawText("Moscrif SDK", 10, 200, paint1);
    c.drawText("Moscrif SDK", 10, 300, paint2);
    c.drawText("Moscrif SDK", 10, 400, paint3);
    c.drawText("Moscrif SDK", 10, 500, paint4);
    c.drawText("Moscrif SDK", 10, 600, paint5);
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