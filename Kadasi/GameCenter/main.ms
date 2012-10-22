include "lib://core/log.ms"
include "lib://game2d/game.ms"
include "lib://game2d/layer.ms"
include "lib://game2d/label.ms"
include "lib://game2d/textButton.ms"
include "lib://game2d/sceneTransitions/slideToTop.ms"
include "lib://game2d/sceneTransitions/slideToBottom.ms"

class GameMenu : Layer
{
    function init()
    {
        super.init();

        this._gamecenter = new Gamecenter("", ["offline_access", "status_update", "read_stream", "publish_stream"]);
        this._paint = new Paint();
//      this._paint.typeface = Typeface.fromName("freemono-r");
        this._paint.color = 0xBF00003F;
        this._paint.textSize = 48;
        this._paint.textAlign = #left;
        this._paint.style = #fill;

        logI("this.width", this._width, "this.height", this._height);
        this._labelTest = new Label({
            text     : "Gamecenter",
            x        : System.width / 2,
            y        : System.height / 15,
            paint    : this._paint/*,
            color    : 0xBF1F1F4F,
            textSize : 48*/
        });
        this._labelTest.setText = function(v)
        {
            var oldWidth = this.width;
            this.text = v;
            this.x = this.x - (this.width - oldWidth) / 2;
        }
        this.add(this._labelTest);

        this._fromValue = function(value)
        {
            var result = "";
            switch (typeof(value)) {
            case #array:
                result += "[";
                for (var i = 0; i < value.length; i++)
                    result += this super._fromValue(value[i]) + ", ";
                result = result.substring(0, result.length - 2) + "]";
                break;
            case #object:
                for (var item in value)/* {*/
                    result = item + " = " + this super._fromValue(value.propertyAt(item)) + ", " + result;
/*                  if (item == "url")
                        if (value.propertyAt(item).substring(value.propertyAt(item).length - 4, value.propertyAt(item).length) == ".jpg" ||
                            value.propertyAt(item).substring(value.propertyAt(item).length - 4, value.propertyAt(item).length) == ".png" ||
                            value.propertyAt(item).substring(value.propertyAt(item).length - 4, value.propertyAt(item).length) == ".gif")
                            app.Bitmap_FromUrl(value.propertyAt(item));
                }*/
                result = "{" + result.substring(0, result.length - 2) + "}";
                break;
            case #Bitmap:
                result = "Bitmap (" + value.width + ", " + value.height + ") (" + typeof(value) + ")";
                break;
            default:
                result += value + " (" + typeof(value) + ")";
            }
            return result;
        }

        this._login = false;
        this._gamecenter.onLogin = function()
        {
            logI("onLogin Login");
            this super._login = true;
            this super._buttonLoginLogout.setText("Logout");
            this super._labelTest.setText("Gamecenter LoggedIn");
        }
        this._gamecenter.onLoginFailed = function(status)
        {
            logI("onLoginFailed : ", status.debugShow(), typeof(status), "\n", this super._fromValue(status));
            this super._sceneResult("onLoginFailed :", this super._fromValue(status));
            this super._login = false;
            this super._buttonLoginLogout.setText("Login");
            this super._labelTest.setText("Gamecenter LoggedOut");
        }
        this._gamecenter.onLogout = function()
        {
            logI("onLogout Logout");
            this super._login = false;
            this super._buttonLoginLogout.setText("Login");
            this super._labelTest.setText("Gamecenter LoggedOut");
        }
        this._gamecenter.onLogoutFailed = function(status)
        {
            logI("onLogoutFailed : ", status.debugShow(), typeof(status), "\n", this super._fromValue(status));
            this super._sceneResult("onLogoutFailed :", this super._fromValue(status));
            this super._login = false;
            this super._buttonLoginLogout.setText("Login");
            this super._labelTest.setText("Gamecenter LoggedOut");
        }
        this._buttonLoginLogout = new TextButton({
            text   : "Login",
            x      : System.width / 2,
            y      : System.height / 15 * 2,
            paint  : this._paint
        });
        this._buttonLoginLogout.onClick = function()
        {
            if (this super._login) {
                logI("Logout");
                this super._gamecenter.logout();
            } else {
                logI("Login");
                this super._gamecenter.login();
            }
//          this super._addRotateScene();
//          Game.instance.push(new RotateScene(), new SlideToTop());
        }
        this._buttonLoginLogout.setText = function(v)
        {
            var oldWidth = this.width;
            this.text = v;
            this.x = this.x - (this.width - oldWidth) / 2;
        }
        this.add(this._buttonLoginLogout);

        this._sceneResult = function(text, value)
        {
            if (value) {
                this._resultScene = new ResultScene();
                this._resultScene._labelTest.setText(text);
                this._resultScene.draw = function(canvas)
                {
                    this._paint = new Paint();
                    this._paint.color = this super._paint.color;
                    this._paint.textSize = 20;
                    this._paint.textAlign = this super._paint.textAlign;
                    this._paint.style = this super._paint.style;
                    super.draw(canvas);
                    if (value)
                        switch (typeof(value)) {
                        case #Bitmap:
                            logI("resultScene.Draw", text, value);
                            canvas.drawBitmap(value, (System.width - value.width) / 2 , (System.height - 100 - value.height) / 2, this._paint);
                            break;
                        default:
                            canvas.drawTextBox(value, 5, Math.ceil(System.height / 25 * 1.2), System.width - 10, Math.ceil(System.height / 25 * 24.2), this._paint);
                        }
                    else
                        canvas.clear(0xBF00003F);
                }
                MyGame.instance.push(this._resultScene, new SlideToTop());
            } else
                logI("_sceneResult(null)");
        }
    
        this._bitmapFromUrl = function(url)
        {
            var wc = new WebClient();
            // show error message if some error appeared
            wc.onError = function(sender)
            {
                logI("WebClient.onError");
            }
            // show number of received bytes
            wc.onReceiving = function(sender, received, total)
            {
                // total can be 0, depends on the server behaviour
                logI("WebClient.onReceiving : ", received, " bytes");
            }
            // show image, when it is downloaded
            wc.onReceived = function(sender)
            {
                // transfer dota into bitmap
                var bitmap = Bitmap.fromBytes(sender.data);
                switch (typeof(bitmap)) {
                case #Bitmap:
                    logI("WebClient.onReceived : #Bitmap : ", typeof(bitmap), bitmap);
                    this super._sceneResult("WebClient.onReceived : #Bitmap :", bitmap);
                    break;
                default:
                    logI("WebClient.onReceived : Default : ", typeof(bitmap), bitmap);
                    this super._sceneResult("WebClient.onReceived : Default :", typeof(bitmap) + ' ' + this super._fromValue(bitmap));
                }
            }
            wc.onCancel = function(sender)
            {
                logI("WebClient.onCancel");
            }
            if (url.substring(0, 7) == "http://") {
                // connect to the server
                wc.open(url.substring(7, url.substring(7, url.length).indexOf("/") + 7), 80, false, "");
                //get picture from the server (from [server address]/userfiles/moscrif2.png)
                wc.getData(url.substring(url.substring(7, url.length).indexOf("/") + 7, url.length));
            } else if (url.substring(0, 8) == "https://") {
                // connect to the server
                wc.open(url.substring(8, url.substring(8, url.length).indexOf("/") + 8), 443, true, "");
                //get picture from the server (from [server address]/userfiles/moscrif2.png)
                wc.getData(url.substring(url.substring(8, url.length).indexOf("/") + 8, url.length));
            }
        }
        this._gamecenter.onRequest = function(result)
        {
            logI("onRequest : ", result.debugShow(), typeof(result), "\n", this super._fromValue(result));
            var bmp = false;
/*          if (typeof(result) == #object)
                for (var item1 in result)
                    if (item1 == "picture")
                        if (typeof(result.propertyAt(item1)) == #object)
                            for (var item2 in result.propertyAt(item1))
                                if (item2 == "data")
                                    if (typeof(result.propertyAt(item1).propertyAt(item2)) == #object)
                                        for (var item3 in result.propertyAt(item1).propertyAt(item2))
                                            if (item3 == "url") {
                                                this super._bitmapFromUrl(result.propertyAt(item1).propertyAt(item2).propertyAt(item3));
                                                bmp = true;
                                            }*/
            if (typeof(result) == #object)
                for (var item1 in result)
                    if (item1 == "data")
                        if (typeof(result.propertyAt(item1)) == #object)
                            for (var item2 in result.propertyAt(item1))
                                if (item2 == "url") {
                                    this super._bitmapFromUrl(result.propertyAt(item1).propertyAt(item2));
                                    bmp = true;
                                }
            if (!bmp)
                this super._sceneResult("onRequest :", this super._fromValue(result));
        }
        this._gamecenter.onRequestFailed = function(error)
        {
            logI("onRequestFailed : ", error.debugShow(), typeof(error), "\n", this super._fromValue(error));
            this super._sceneResult("onRequestFailed :", this super._fromValue(error));
        }
        this._buttonRequestGetMe = new TextButton({
            text   : "Request Get (me)",
            x      : System.width / 2,
            y      : System.height / 15 * 3,
            paint  : this._paint
        });
        this._buttonRequestGetMe.onClick = function()
        {
            logI("Request Get (me)");
            if (this super._login)
                this super._gamecenter.request("me");
            else
                this super._sceneResult("LooggedOut", "onRequest : LooggedOut");
        }
        this.add(this._buttonRequestGetMe);

        this._buttonRequestGetMeFriends = new TextButton({
            text   : "Request Get (me/friends)",
            x      : System.width / 2,
            y      : System.height / 15 * 4,
            paint  : this._paint
        });
        this._buttonRequestGetMeFriends.onClick = function()
        {
            logI("Request Get (me/friends)");
            if (this super._login)
                this super._gamecenter.request("me/friends", #get);
            else
                this super._sceneResult("LooggedOut", "onRequest : LooggedOut");
        }
        this.add(this._buttonRequestGetMeFriends);

        this._buttonRequestGetMePicture = new TextButton({
            text   : "Request Get (me/picture)",
            x      : System.width / 2,
            y      : System.height / 15 * 5,
            paint  : this._paint
        });
        this._buttonRequestGetMePicture.onClick = function()
        {
            logI("Request Get (me/picture)");
            if (this super._login)
                this super._gamecenter.request("me/picture", #get, {redirect: false, type: "large"});
            else
                this super._sceneResult("LooggedOut", "onRequest : LooggedOut");
        }
        this.add(this._buttonRequestGetMePicture);

        this._buttonRequestPostStatus = new TextButton({
            text   : "Request Post (feed status)",
            x      : System.width / 2,
            y      : System.height / 15 * 6,
            paint  : this._paint
        });
        this._buttonRequestPostStatus.onClick = function()
        {
            logI("Request Post (feed status)");
            if (this super._login)
                this super._gamecenter.request("me/feed", #post, {title: "Moscrif Test", type: "status", message: "Moscrif Test.", description: "Moscrif test."});
            else
                this super._sceneResult("LooggedOut", "onRequest : LooggedOut");
        }
        this.add(this._buttonRequestPostStatus);

        this._buttonRequestPostLink = new TextButton({
            text   : "Request Post (feed link)",
            x      : System.width / 2,
            y      : System.height / 15 * 7,
            paint  : this._paint
        });
        this._buttonRequestPostLink.onClick = function()
        {
            logI("Request Post (feed link)");
            if (this super._login)
                this super._gamecenter.request("me/feed", #post, {title: "Moscrif Test", type: "link", link: "http://moscrif.com", picture: "http://moscrif.com/images/logo.png", description: "Moscrif test."});
            else
                this super._sceneResult("LooggedOut", "onRequest : LooggedOut");
        }
        this.add(this._buttonRequestPostLink);

        this.bitmap = Bitmap.fromFile("app://photo.jpg");
        this._buttonRequestPostPhoto = new TextButton({
            text   : "Request Post (photo)",
            x      : System.width / 2,
            y      : System.height / 15 * 8,
            paint  : this._paint
        });
        this._buttonRequestPostPhoto.onClick = function()
        {
            logI("Request Post (photo)");
            if (this super._login)
                this super._gamecenter.request("me/photos", #post, {title: "Moscrif Test", source: this super.bitmap, message: "Moscrif Test.", description: "Moscrif test."});
            else
                this super._sceneResult("LooggedOut", "onRequest : LooggedOut");
        }
        this.add(this._buttonRequestPostPhoto);

        this._gamecenter.onDialog = function(result)
        {
            logI("onDialog : ", typeof(result) == #string ? result : result.debugShow(), typeof(result), "\n", this super._fromValue(result));
            this super._sceneResult("onDialog :", this super._fromValue(result));
        }
        this._gamecenter.onDialogFailed = function(error)
        {
            logI("onDialogFailed : ", typeof(error) == #string ? error : error.debugShow(), typeof(error), "\n", this super._fromValue(error));
            this super._sceneResult("onDialogFailed :", this super._fromValue(error));
        }
        this._buttonRequestView = new TextButton({
            text   : "Request View (feed)",
            x      : System.width / 2,
            y      : System.height / 15 * 9,
            paint  : this._paint
        });
        this._buttonRequestView.onClick = function()
        {
            logI("Request View (feed)");
            if (this super._login)
                this super._gamecenter.dialog("feed", {caption: "Moscrif Test.", link: "http://moscrif.com", picture: "http://moscrif.com/images/logo.png", actions: {name: "Moscrif Test", link: "http://moscrif.com"}, description: "Moscrif test."});
            else
                this super._sceneResult("LooggedOut", "onRequest : LooggedOut");
        }
        this.add(this._buttonRequestView);

/*
        if (System.OS_NAME != #iOS) {*/
            this._buttonQuit = new TextButton({
                text   : "Quit",
                x      : System.width / 2,
                y      : System.height / 15 * 14.5,
                paint  : this._paint
            });
            this._buttonQuit.onClick = function()
            {
                logI("Quit");
                MyGame.quit();
            }
            this.add(this._buttonQuit);/*
        } else {
            this._buttonQuit = 0;
        }*/
    }

/*
    property scene(v)
    {
        get return this._scene;
        set this._scene = v;
    }

    property x(v)
    {
        get return this._x;
        set this._x = v;
    }

    property y(v)
    {
        get return this._y;
        set this._y = v;
    }

    property width(v)
    {
        get return this._width;
        set this._width = v;
    }

    property height(v)
    {
        get return this._height;
        set this._height = v;
    }

    function draw(canvas)
    {
/*      canvas.save();
        canvas.translate(this.x, this.y);
        canvas.restore();*-/
        super.draw(canvas);
    }*/
}

class GameScene : Scene
{
    function init()
    {
        super.init();
        this._menu = new GameMenu({
            scene      : this,
            x          : 5,
            y          : 5,
//          frameWidth : System.width - 10,
            width      : System.width - 10,
            height     : System.height - 10
        });
        this.add(this._menu);
//      this._menu._visible = true;
    }

/*  function draw(canvas)
    {
        super.draw(canvas);
    }*/
}

class ResultScene : Scene
{
    function init()
    {
        super.init();
        this._paint = new Paint();
//      this._paint.typeface = Typeface.fromName("freemono-r");
        this._paint.color = 0xBF00003F;
        this._paint.textSize = 36;
        this._paint.textAlign = #left;
        this._paint.style = #fill;

        this._labelTest = new Label({
            text     : "Gamecenter",
            x        : System.width / 2,
            y        : System.height / 25 * 0.9,
            paint    : this._paint/*,
            color    : 0xBF1F1F4F,
            textSize : 48*/
        });
        this._labelTest.setText = function(v)
        {
            var oldWidth = this.width;
            this.text = v;
            this.x = this.x - (this.width - oldWidth) / 2;
        }
        this.add(this._labelTest);

        this._buttonBack = new TextButton({
            text   : "Back",
            x      : System.width / 2,
            y      : System.height / 25 * 24.7,
            paint  : this._paint
        });
        this._buttonBack.onClick = function()
        {
            logI("Back");
            this super._goBack();
        }
        this.add(this._buttonBack);
    }

    function _goBack()
    {
        MyGame.instance.pop(new SlideToBottom());
    }

/*  function draw(canvas)
    {
        canvas.save();
        canvas.translate(this.x, this.y);
        canvas.restore();*-/
        super.draw(canvas);
    }

    function exit()
    {
        ;
    }*/
}

class MyGame : Game
{
    function start()
    {
        this._bg = Bitmap.fromFile("app://game_back.png");

        this._game = new GameScene();
        this.push(this._game);
    }

    function onStart()
    {
        logI("onStart");
    }

    function onKeyPressed(keyCode)
    {
        if (keyCode == #back || keyCode == #home) {
            logI("Quit");
            MyGame.quit();
        }
    }

    function draw(canvas)
    {
        canvas.drawBitmap(this._bg, 0, 0);
        super.draw(canvas);
    }
}

new MyGame().run();