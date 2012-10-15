include "lib://core/log.ms"
include "lib://core/animation/transition.ms"
include "lib://game2d/game.ms"
include "lib://game2d/sprite.ms"

class MyGame : Game
{
    function start()
    {
        this._bg = Bitmap.fromFile("app://game_back.png");
        this._sprite = new Sprite({image: "app://cloud_horny.png", x:System.width/2, y:System.height/8});

        var paint = new Paint();
        paint.color = 0xff0000ff;
        paint.style = #stroke;

        this._textXxx_Return = function(sender, text)
        {
            logI(sender, "Return,", text);
        }
        this._textXxx_Change = function(sender, after, before, from, to)
        {
            switch (from) {
            case #space:
                from = "#space";
                break;
            case #enter:
                from = "#enter";
                break;
            }
            switch (to) {
            case #space:
                to = "#space";
                break;
            case #enter:
                to = "#enter";
                break;
            case #backspace:
                to = "#backspace";
                break;
            }
            logI(sender, "Change,", before, "(", from, "=>", to, ")", after);
            return true;
        }

        this._backgroundPaint = new Paint();
        this._backgroundPaint.style = #stroke;
        this._backgroundPaint.color = 0x3F0000FF;
        this._backgroundPaint.typeface = Typeface.fromName("freesans");
        this._backgroundPaint.textSize = 16;

        this._foregroundPaint = new Paint();
        this._foregroundPaint.style = #fill;
        this._foregroundPaint.color = 0xFF00007F;
        this._foregroundPaint.typeface = Typeface.fromName("freesans");
        this._foregroundPaint.textSize = 16;

        this._borderPaint = new Paint();
        this._borderPaint.style = #fill;
        this._borderPaint.color = 0xBF0000FF;
        this._borderPaint.typeface = Typeface.fromName("freesans");
        this._borderPaint.textSize = 16;

        this._textField_1 = new Moscrif.View();
        var subclass_TextField_1 = this._textField_1.subclass("TextField");
        if (subclass_TextField_1) {
            subclass_TextField_1.zoomable = true;
            subclass_TextField_1.background = this._backgroundPaint;
            subclass_TextField_1.foreground = this._foregroundPaint;
            subclass_TextField_1.border = this._borderPaint;
//          subclass_TextField_1.backgroundColor = 0x3F0000FF;
            subclass_TextField_1.showTextField("Test.", this._textXxx_Return, this._textXxx_Change);
//          logI("TextField_1.background", subclass_TextField_1.background);
        }
        this._textField_1.onDraw = function(sender, canvas) {
            canvas.drawRect(0, 0, sender.width, sender.height, paint);
        }
        this._textField_1.left = 50;
        this._textField_1.top = 50;
        this._textField_1.width = Math.floor(System.width/2 - 1.5*this._textField_1.left);
        this._textField_1.height = 50;
        this._window.add(this._textField_1);

        this._textField_2 = new Moscrif.View();
        var subclass_TextField_2 = this._textField_2.subclass("TextField");
        if (subclass_TextField_2) {
            subclass_TextField_2.zoomable = true;
            subclass_TextField_2.background = this._backgroundPaint;
            subclass_TextField_2.foreground = this._foregroundPaint;
            subclass_TextField_2.border = this._borderPaint;
//          subclass_TextField_2.backgroundColor = 0x3F0000FF;
            subclass_TextField_2.showTextField("Test.", this._textXxx_Return/*, this._textXxx_Change*/);
//          logI("TextField_2.background", subclass_TextField_2.background);
        }
        this._textField_2.onDraw = function(sender, canvas) {
            canvas.drawRect(0, 0, sender.width, sender.height, paint);
        }
        this._textField_2.left = Math.floor(System.width/2 + 0.5*this._textField_1.left);
        this._textField_2.top = this._textField_1.top;
        this._textField_2.width = Math.floor(System.width/2 - 1.5*this._textField_1.left);
        this._textField_2.height = this._textField_1.height;
        this._window.add(this._textField_2);

        this._textView = new Moscrif.View();
        var subclass_TextView = this._textView.subclass("TextView");
        if (subclass_TextView) {
            subclass_TextView.zoomable = true;
            subclass_TextView.background = this._backgroundPaint;
            subclass_TextView.foreground = this._foregroundPaint;
            subclass_TextView.border = this._borderPaint;
//          subclass_TextView.backgroundColor = 0x3F0000FF;
            subclass_TextView.showTextView("Test.", this._textXxx_Return, this._textXxx_Change);
//          logI("TextView.background", subclass_TextView.background);
        }
        this._textView.onDraw = function(sender, canvas) {
            canvas.drawRect(0, 0, sender.width, sender.height, paint);
        }
        this._textView.left = 50;
        this._textView.top = 150;
        this._textView.width = System.width - 2*this._textView.left;
        this._textView.height = System.height - this._textView.top - 50;
        this._window.add(this._textView);

        this.add(this._sprite);
        Transition.to(this._sprite, {angle:Math.PI, duration:10000, onComplete:function(){Transition.to(this super._sprite, {angle:2*Math.PI, duration:10000})}});
    }

    function draw(canvas)
    {
        canvas.drawBitmap(this._bg, 0, 0);
    }
}

new MyGame().run();
