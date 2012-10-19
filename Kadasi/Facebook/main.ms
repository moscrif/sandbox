include "lib://core/log.ms"
include "lib://game2d/game.ms"
include "lib://game2d/layer.ms"
include "lib://game2d/label.ms"
include "lib://game2d/textButton.ms"

class GameMenu : Layer
{
    function init()
    {
        super.init();

        if (Facebook.isAvailable())
            logI("Facebook.isAvailable true");
        else
            logI("Facebook.isAvailable false");
        this._facebook = new Facebook("", ["offline_access", "status_update", "read_stream", "publish_stream"]);

        var _paint = new Paint();
//      _paint.typeface = Typeface.fromName("freemono-r");
        _paint.color = 0xBF00003F;
        _paint.textSize = 48;
        _paint.textAlign = #left;
        _paint.style = #fill;

        logI("this.width", this._width, "this.height", this._height);
        this._labelTest = new Label({
            text     : "FaceBook",
            x        : System.width / 2,
            y        : System.height / 15,
            paint    : _paint/*,
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

        this.fromValue = function(value)
        {
            var result = "";
            switch (typeof(value)) {
            case #array:
                result += "[";
                for (var i = 0; i < value.length; i++)
                    result += app.fromValue(value[i]) + ", ";
                result = result.substring(0, result.length - 2) + "]";
                break;
            case #object:
                for (var item in value)/* {*/
                    result = item + " = " + this.fromValue(value.propertyAt(item)) + ", " + result;
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

        this.sceneResult = function(value)
        {
            var formRes = new Form({name: "formRes"});
            formRes.onActivate = function(sender)
            {
                ;//logI("formRes");
            }
    
            var toolsRes = new ToolBar({height: 100});
            formRes.add(toolsRes);
            toolsRes.add(new ToolBarButton({icon: #quit, text: "quit", onClick: function(sender) { app.pop(formRes); formRes.detach(); }}));
    
            formRes.onDraw = function(sender, canvas)
            {
                if (value)
                    switch (typeof(value)) {
                    case #Bitmap:
                        canvas.drawBitmap(value, (System.width - value.width) / 2 , (System.height - 100 - value.height) / 2, app._paint);
                        break;
                    default:
                        canvas.drawTextBox(value, 0, 100, System.width, System.height, app._paint);
                    }
                else
                    canvas.clear(0xFF000000);
            }
            app.push(formRes);
        }
    
        this.Bitmap_FromUrl = function(url)
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
                    app.formResult(bitmap);
                    break;
                default:
                    logI("WebClient.onReceived : Default : ", typeof(bitmap), bitmap);
                    app.formResult("WebClient.onReceived : Default : ", typeof(bitmap), app.fromValue(bitmap));
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

        this._login = false;
        this._facebook.onLogin = function()
        {
            logI("onLogin Login");
            this._login = true;
            this._buttonLoginLogout.setText("Logout");
            this._labelTest.setText("Facebook LoggedIn");
        }
        this._facebook.onLoginFailed = function(status)
        {
            logI("onLoginFailed : ", status.debugShow(), typeof(status), "\n", this.fromValue(status));
            this.sceneResult("onLoginFailed : " + this.fromValue(status));
            this._login = false;
            this._buttonLoginLogout.setText("Login");
            this._labelTest.setText("Facebook LoggedOut");
        }
        this._facebook.onLogout = function()
        {
            logI("onLogout Logout");
            this._login = false;
            this._buttonLoginLogout.setText("Login");
            this._labelTest.setText("Facebook LoggedOut");
        }
        this._facebook.onLogoutFailed = function(status)
        {
            logI("onLogoutFailed : ", status.debugShow(), typeof(status), "\n", app.fromValue(status));
            this.sceneResult("onLogoutFailed : " + this.fromValue(status));
            this._login = false;
            this._buttonLoginLogout.setText("Login");
            this._labelTest.setText("Facebook LoggedOut");
        }
        this._buttonLoginLogout = new TextButton({
            text   : "Login",
            x      : System.width / 2,
            y      : System.height / 15 * 2,
            paint  : _paint
        });
        this._buttonLoginLogout.onClick = function()
        {
            if (this.login) {
                logI("Logout");
                this._facebook.logout();
            } else {
                logI("Login");
                this._facebook.login();
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

        this._buttonRequestGetMe = new TextButton({
            text   : "Request Get (me)",
            x      : System.width / 2,
            y      : System.height / 15 * 3,
            paint  : _paint
        });
        this._buttonRequestGetMe.onClick = function()
        {
            logI("Request Get (me)");
//          app.login ? _facebook.request("me") : this.sceneResult("LooggedOut");
        }
        this.add(this._buttonRequestGetMe);

        this._buttonRequestGetMeFriends = new TextButton({
            text   : "Request Get (me/friends)",
            x      : System.width / 2,
            y      : System.height / 15 * 4,
            paint  : _paint
        });
        this._buttonRequestGetMeFriends.onClick = function()
        {
            logI("Request Get (me/friends)");
//          app.login ? _facebook.request("me/friends", #get) : this.sceneResult("LooggedOut");
        }
        this.add(this._buttonRequestGetMeFriends);

        this._buttonRequestGetMePicture = new TextButton({
            text   : "Request Get (me/picture)",
            x      : System.width / 2,
            y      : System.height / 15 * 5,
            paint  : _paint
        });
        this._buttonRequestGetMePicture.onClick = function()
        {
            logI("Request Get (me/picture)");
//          app.login ? _facebook.request("me/picture", #get, {redirect: false, type: "large"}) : this.sceneResult("LooggedOut");
        }
        this.add(this._buttonRequestGetMePicture);

        this._buttonRequestPostStatus = new TextButton({
            text   : "Request Post (feed status)",
            x      : System.width / 2,
            y      : System.height / 15 * 6,
            paint  : _paint
        });
        this._buttonRequestPostStatus.onClick = function()
        {
            logI("Request Post (feed status)");
//          app.login ? _facebook.request("me/feed", #post, {title: "Moscrif Test", type: "status", message: "Moscrif Test.", description: "Moscrif test."}) : this.sceneResult("LooggedOut");
        }
        this.add(this._buttonRequestPostStatus);

        this._buttonRequestPostLink = new TextButton({
            text   : "Request Post (feed link)",
            x      : System.width / 2,
            y      : System.height / 15 * 7,
            paint  : _paint
        });
        this._buttonRequestPostLink.onClick = function()
        {
            logI("Request Post (feed link)");
//          app.login ? _facebook.request("me/feed", #post, {title: "Moscrif Test", type: "link", link: "http://moscrif.com", picture: "http://moscrif.com/images/logo.png", description: "Moscrif test."}) : this.sceneResult("LooggedOut");
        }
        this.add(this._buttonRequestPostLink);

        this.bitmap = Bitmap.fromFile("app://photo.jpg");
        this._buttonRequestPostPhoto = new TextButton({
            text   : "Request Post (photo)",
            x      : System.width / 2,
            y      : System.height / 15 * 8,
            paint  : _paint
        });
        this._buttonRequestPostPhoto.onClick = function()
        {
            logI("Request Post (photo)");
//          app.login ? _facebook.request("me/photos", #post, {title: "Moscrif Test", source: app.bitmap, message: "Moscrif Test.", description: "Moscrif test."}) : this.sceneResult("LooggedOut");
        }
        this.add(this._buttonRequestPostPhoto);
/*
        this._facebook.onDialog = function(result)
        {
            logI("onDialog : ", result.debugShow(), typeof(result), "\n", this.fromValue(result));
            this.sceneResult("onDialog : " + this.fromValue(result));
        }
        this._facebook.onDialogFailed = function(error)
        {
            logI("onDialogFailed : ", error.debugShow(), typeof(error), "\n", this.fromValue(error));
            this.sceneResult("onDialogFailed : " + this.fromValue(error));
        }*/
        this._buttonRequestView = new TextButton({
            text   : "Request View (feed)",
            x      : System.width / 2,
            y      : System.height / 15 * 9,
            paint  : _paint
        });
        this._buttonRequestView.onClick = function()
        {
            logI("Request View (feed)");
//          app.login ? _facebook.dialog("feed", {caption: "Moscrif Test.", link: "http://moscrif.com", picture: "http://moscrif.com/images/logo.png", actions: {name: "Moscrif Test", link: "http://moscrif.com"}, description: "Moscrif test."}) : app.formResult("LooggedOut");
        }
        this.add(this._buttonRequestView);

/*
        if (System.OS_NAME != #iOS) {*/
            this._buttonQuit = new TextButton({
                text   : "Quit",
                x      : System.width / 2,
                y      : System.height / 15 * 14,
                paint  : _paint
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
*/
/*    function draw(canvas)
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
      this._menu._visible = true;
    }

    function draw(canvas)
    {
        super.draw(canvas);
    }
}

class MyGame : Game
{
    function start()
    {
        this._bg = Bitmap.fromFile("app://game_back.png");
//        this._facebook = new Facebook("", ["offline_access", "status_update", "read_stream", "publish_stream"]);

        this._game = new GameScene();
        this.push(this._game);
    }

    function onStart()
    {
        logI("onStart");
    }

    function onKeyPressed(keyCode)
    {
        if (keyCode == #back || keyCode == #home)
            game.quit();
    }

    function draw(canvas)
    {
        canvas.drawBitmap(this._bg, 0, 0);
        super.draw(canvas);
    }
}

new MyGame().run();