var app = new Moscrif.Window();

var bitmap = Bitmap.fromFile("app://sunflowers.jpg");

var paint1 = new Paint();
paint1.imageFilter = ImageFilter.blur(5, 5);

var paint2 = new Paint();
paint2.imageFilter = ImageFilter.blur(10, 10);

var paint3 = new Paint();
paint3.imageFilter = ImageFilter.blur(25, 25);

app.onDraw = function(s, c)
{
    c.clear(0xff000000);
    c.drawBitmap(bitmap, 10, 10);
    c.drawBitmap(bitmap, 330, 10, paint1);
    c.drawBitmap(bitmap, 10, 300, paint2);
    c.drawBitmap(bitmap, 330, 300, paint3);
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