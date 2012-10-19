include "lib://core/log.ms"
include "lib://game2d/game.ms"
include "lib://graphics/paintCache.ms"

class MySprite : Sprite
{
    function draw(canvas)
    {
        canvas.save(#matrix);
        canvas.translate(this._x, this._y);
        canvas.rotate(-(this.angle * 180. / Math.PI)); // rad2deg
        canvas.scale(this._scale, this._scale);
        canvas.translate(-this._anchorX, -this._anchorY);

        var p = PaintCache.getPaint(MySprite);
        canvas.drawRect(0, 0, this.width, this.height, p);
        canvas.drawTextBox(this._text||"undefined", 0, 0, this.width, this.height, p, #center);

        canvas.restore();
    }

    property text(v) {
        get return this._text;
        set this._text = v;
    }
}

// custom game class
class DeviceOrientationInGame : Game
{

    function start()
    {
        super.start();
        // additional initialization code goes here

        // prepare game
        this._initSprites();

        // allow change of orientation
        this.orientation = [#portrait, #landscape-left];

        var paint = new Paint();
        paint.color = 0xffffffff;
        paint.style = #stroke;
        paint.textAlign = #center;

        PaintCache.storePaint(MySprite, paint);
    }

    function draw(canvas)
    {
        // custom drawings - background
        canvas.clear(0xff0000aa);

        // default drawings
        super.draw(canvas);
    }

    function process()
    {
        // just rotate a sprite
        this._sprite.angle += 0.05;
    }

    function orientationChanged(orientation)
    {
        this._sprite.text = orientation.toString();
        this._sprite.x = System.width / 2;
        this._sprite.y = System.height / 2;
    }

    function _initSprites()
    {
        // create one sprite (crate)
        this._sprite = new MySprite({x:System.width/2, y:System.height/2, width:300, height:100});
        // add sprite to game
        this.add(this._sprite);
    }

}

// create instace and run the game
new DeviceOrientationInGame().run();
