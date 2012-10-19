include "lib://core/log.ms"

include "lib://uix/application.ms"
include "lib://uix/control/navigation/titleBar.ms"
include "lib://uix/control/navigation/toolBar.ms"
include "lib://uix/control/navigation/toolBarButton.ms"
include "lib://uix/control/list/list.ms"
include "lib://uix/control/list/listItem.ms"

var app = new Application();

var _facebook = new Facebook("", ["offline_access", "status_update", "read_stream", "publish_stream"]);

app.onStart = function(sender)
{
    var form = new Form({name: "mainForm"});

//  form.add(new TitleBar({title: "Facebook"}));
    var title = new TitleBar({title: "Facebook", height: 100});
    form.add(title);

/*  app.list = new List({stretch: #both});
    form.add(app.list);*/

    app.fromValue = function(value)
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
                result = item + " = " + app.fromValue(value.propertyAt(item)) + ", " + result;
/*              if (item == "url")
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

    app.login = false;
    _facebook.onLogin = function()
    {
        logI("onLogin Login");
        app.login = true;
        app.Login.text = "Logout";
        title.title = "Facebook LoggedIn";
    }
    _facebook.onLoginFailed = function(status)
    {
        logI("onLoginFailed : ", status.debugShow(), typeof(status), "\n", app.fromValue(status));
        app.formResult("onLoginFailed : " + app.fromValue(status));
        app.login = false;
        app.Login.text = "Login";
        title.title = "Facebook LoggedOut";
    }
//  form.add(new Button({text: "Login", onClick: ::app.login?_facebook.logout():_facebook.login()}));
    app.Login = new Button({text: "Login", onClick: function(sender) { app.login ? _facebook.logout() : _facebook.login(); }, height: 75});
    form.add(app.Login);
//  app.list.add(new ListItem({text: "Login", onClick: ::_facebook.login()}));
    _facebook.onLogout = function()
    {
        logI("onLogout Logout");
        app.login = false;
        app.Login.text = "Login";
        title.title = "Facebook LoggedOut";
    }
    _facebook.onLogoutFailed = function(status)
    {
        logI("onLogoutFailed : ", status.debugShow(), typeof(status), "\n", app.fromValue(status));
        app.formResult("onLogoutFailed : " + app.fromValue(status));
        app.login = false;
        app.Login.text = "Login";
        title.title = "Facebook LoggedOut";
    }
//  form.add(new Button({text: "Logout", onClick: ::_facebook.logout()}));
//  app.list.add(new ListItem({text: "Logout", onClick: ::_facebook.logout()}));

    app._paint = new Paint();
    app._paint.color = 0xFF000000;
    app._paint.textSize = 20;
    app.formResult = function(value)
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

    app.Bitmap_FromUrl = function(url)
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

    _facebook.onRequest = function(result)
    {
        logI("onRequest : ", result.debugShow(), typeof(result), "\n", app.fromValue(result));
        var bmp = false;
/*      if (typeof(result) == #object)
            for (var item1 in result)
                if (item1 == "picture")
                    if (typeof(result.propertyAt(item1)) == #object)
                        for (var item2 in result.propertyAt(item1))
                            if (item2 == "data")
                                if (typeof(result.propertyAt(item1).propertyAt(item2)) == #object)
                                    for (var item3 in result.propertyAt(item1).propertyAt(item2))
                                        if (item3 == "url") {
                                            app.Bitmap_FromUrl(result.propertyAt(item1).propertyAt(item2).propertyAt(item3));
                                            bmp = true;
                                        }*/
        if (typeof(result) == #object)
            for (var item1 in result)
                if (item1 == "data")
                    if (typeof(result.propertyAt(item1)) == #object)
                        for (var item2 in result.propertyAt(item1))
                            if (item2 == "url") {
                                app.Bitmap_FromUrl(result.propertyAt(item1).propertyAt(item2));
                                bmp = true;
                            }
        if (!bmp)
            app.formResult("onRequest : " + app.fromValue(result));
    }
    _facebook.onRequestFailed = function(error)
    {
        logI("onRequestFailed : ", error.debugShow(), typeof(error), "\n", app.fromValue(error));
        app.formResult("onRequestFailed : " + app.fromValue(error));
    }
    form.add(new Button({text: "Request Get (me)", onClick: function(sender) { app.login ? _facebook.request("me") : app.formResult("LooggedOut"); }, height: 75}));
//  app.list.add(new ListItem({text: "Request Get (me)", onClick: ::_facebook.request("me", #get)}));

    form.add(new Button({text: "Request Get (me/friends)", onClick: function(sender) { app.login ? _facebook.request("me/friends", #get) : app.formResult("LooggedOut"); }, height: 75}));
//  app.list.add(new ListItem({text: "Request Get (me/friends)", onClick: ::_facebook.request("me/friends", #get)}));

//  form.add(new Button({text: "Request Get (me/picture)", onClick: function(sender) { app.login ? _facebook.request("me", #get, {fields: "picture"}) : app.formResult("LooggedOut"); }, height: 75}));
    form.add(new Button({text: "Request Get (me/picture)", onClick: function(sender) { app.login ? _facebook.request("me/picture", #get, {redirect: false, type: "large"}) : app.formResult("LooggedOut"); }, height: 75}));
//  app.list.add(new ListItem({text: "Request Get (me/picture)", onClick: ::_facebook.request("me/picture", #get, {redirect: false, type: "large"}));

    form.add(new Button({text: "Request Post (feed status)", onClick: function(sender) { app.login ? _facebook.request("me/feed", #post, {title: "Moscrif Test", type: "status", message: "Moscrif Test.", description: "Moscrif test."}) : app.formResult("LooggedOut"); }, height: 75}));
//  app.list.add(new ListItem({text: "Request Post (feed status)", onClick: ::_facebook.request("me/feed", #post, {title: "Moscrif Test", type: "status", message: "Moscrif Test.", description: "Moscrif test."})}));

    form.add(new Button({text: "Request Post (feed link)", onClick: function(sender) { app.login ? _facebook.request("me/feed", #post, {title: "Moscrif Test", type: "link", link: "http://moscrif.com", picture: "http://moscrif.com/images/logo.png", description: "Moscrif test."}) : app.formResult("LooggedOut"); }, height: 75}));
//  app.list.add(new ListItem({text: "Request Post (feed link)", onClick: ::_facebook.request("me/feed", #post, {title: "Moscrif Tes.", type: "link", link: "http://moscrif.com", picture: "http://moscrif.com/images/logo.png", description: "Moscrif test."})}));

    app.bitmap = Bitmap.fromFile("app://foto.jpg");
    form.add(new Button({text: "Request Post (photo)", onClick: function(sender) { app.login ? _facebook.request("me/photos", #post, {title: "Moscrif Test", source: app.bitmap, message: "Moscrif Test.", description: "Moscrif test."}) : app.formResult("LooggedOut"); }, height: 75}));
//  app.list.add(new ListItem({text: "Request Post (photo)", onClick: ::_facebook.request("me/photos", #post, {title: "Moscrif Test", source: app.bitmap, message: "Moscrif Test.", description: "Moscrif test."})}));

    _facebook.onDialog = function(result)
    {
        logI("onDialog : ", result.debugShow(), typeof(result), "\n", app.fromValue(result));
        app.formResult("onDialog : " + app.fromValue(result));
    }
    _facebook.onDialogFailed = function(error)
    {
        logI("onDialogFailed : ", error.debugShow(), typeof(error), "\n", app.fromValue(error));
        app.formResult("onDialogFailed : " + app.fromValue(error));
    }
    form.add(new Button({text: "Request View (feed)", onClick: function(sender) { app.login ? _facebook.dialog("feed", {caption: "Moscrif Test.", link: "http://moscrif.com", picture: "http://moscrif.com/images/logo.png", actions: {name: "Moscrif Test", link: "http://moscrif.com"}, description: "Moscrif test."}) : app.formResult("LooggedOut"); }, height: 75}));
//  app.list.add(new ListItem({text: "Request View", onClick: ::_facebook.dialog("feed", {caption: "Moscrif Test.", link: "http://moscrif.com", picture: "http://moscrif.com/images/logo.png", actions: {name: "Moscrif Test", link: "http://moscrif.com"}, description: "Moscrif test."})}));

    form.add(new StaticContainer({stretch: #both}));

    var tools = new ToolBar({height: 100});
    form.add(tools);

    var quit = new ToolBarButton({icon: #quit, text: "quit", onClick: function(sender) { app.quit(); }});
    tools.add(quit);

    var menu = new ToolBarButton({icon: #menu});
    tools.add(menu);

    app.push(form);
}

app.onDraw = function(sender, canvas)
{
    canvas.clear(0xffffffff);
}

app.run();
