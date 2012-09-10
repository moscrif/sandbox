
var app = new Moscrif.Window();

// default paint

var paint0 = new Paint();
paint0.style = #stroke;
paint0.textSize = 80;
paint0.color = 0xff0000ff;

// pant with rasterizer

var paint1 = new Paint();
paint1.style = #stroke;
paint1.textSize = 80;
paint1.color = 0xff0000ff;

var p1 = new Paint();
p1.style = #stroke;
var rasterizer1 = new LayerRasterizer();
rasterizer1.add(p1);
paint1.rasterizer = rasterizer1;

// pant with rasterizer

var paint2 = new Paint();
paint2.style = #fill;
paint2.textSize = 80;
paint2.fakeBoldText = true;
paint2.color = 0xff0000ff;
paint2.maskFilter = MaskFilter.emboss(1, 1, 1, 0.1, 0.05, 3);

app.onDraw = function(s, c)
{
    c.clear(0xffffffff);
    c.drawText("Moscrif SDK", 10, 100, paint0);
    c.drawText("Moscrif SDK", 10, 200, paint1);
    c.drawText("Moscrif SDK", 10, 300, paint2);
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