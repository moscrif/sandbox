include "lib://core/log.ms"
include "lib://game2d/game.ms"

class MyGame : Game
{
    function start()
    {
        this._bg = Bitmap.fromFile("app://game_back.png");

        var paint = new Paint();
        paint.color = 0xff0000ff;
        paint.style = #stroke;

    }

    function draw(canvas)
    {
        canvas.drawBitmap(this._bg, 0, 0);
    }
}

new MyGame().run();
