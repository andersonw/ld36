package;

import flixel.addons.display.FlxNestedSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxButtonPlus;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

class BasicGameState extends FlxSubState
{
    public var gameObjects:Array<GameObject>;
    var playSprites:Array<RegularPolygonSprite>;
    var boundingBoxes:Array<FlxRect>;
    var velocities:Array<Point>;
    var aVelocities:Array<Float>;
    var keyLists:Array<Array<FlxKey>>;

    var readyToClose:Bool;

    var width:Float;
    var height:Float;

    var currentlyColliding:Bool;
    var currentlyCollidingBoundary:Bool;
    var printing:Bool;
    var printrightnow:Bool;

    var paused:Bool;
    var pauseMenu:Bool;

    var pauseScreenOutline:FlxSprite;
    var pauseScreenContinue:BetterButton;
    var pauseScreenBack:BetterButton;
    var pauseScreenText:FlxText;

    //stuff for counting down at the beginning of a level
    var countdownText:FlxText;
    var timeToGameStart:Float;
    var gameStarted:Bool;

    var gameRulesText:FlxText;
    var showRules:Bool;

    var polygonHitSound:FlxSound;
    var countdownBeepSound:FlxSound;
    var gameStartSound:FlxSound;

    public static inline var ACCELERATION:Float = 0.2;
    public static inline var ANGULAR_ACCELERATION:Float = 0.4;
    public static inline var ANGULAR_DRAG:Float = 0.96;
    public static inline var ANGULAR_VELOCITY:Float = 5;
    public static inline var VELOCITY:Float = 4;
    public static inline var DRAG:Float = 0.99;
    public static inline var ELASTICITY:Float = .90;
    public static inline var ANGULAR_RECOIL:Float = -0.01;
    public static inline var COLLISION_THRESHOLD:Float = 10;

    public function makeSprite(sprite:RegularPolygonSprite, keymap:Array<FlxKey>, xv:Float = 0, yv:Float = 0, av:Float = 0):Int
    {
        sprite.parent = this;
        playSprites.push(sprite);
        keyLists.push(keymap);
        velocities.push(new Point(xv, yv, -1));
        aVelocities.push(av);
        add(sprite);
        return playSprites.length - 1;
    }
    
    override public function create():Void
    {
        readyToClose = false;

        width = FlxG.width;
        height = FlxG.height;

        gameObjects = new Array<GameObject>();
        playSprites = new Array<RegularPolygonSprite>();
        boundingBoxes = new Array<FlxRect>();
        velocities = new Array<Point>();
        aVelocities = new Array<Float>();
        keyLists = new Array<Array<FlxKey>>();
        
        var boundary:FlxRect = new FlxRect(0, 0, width, height);
        boundingBoxes.push(boundary);
        currentlyCollidingBoundary = false;
        currentlyColliding = false;

        paused = false;
        pauseMenu = false;

        pauseScreenText = new FlxText(310, 100, 1000, "Paused", 20);
        pauseScreenText.setFormat(Registry.FONT_PATH, 20);
        pauseScreenText.x = (width-pauseScreenText.width)/2;

        pauseScreenOutline = new FlxSprite(0, 0);
        pauseScreenOutline.makeGraphic(Math.floor(width), Math.floor(height), FlxColor.WHITE);
        pauseScreenOutline.alpha = 0.3;

        //pauseScreenContinue = new FlxButtonPlus(300, 300, exitPauseMenu, "Continue", 100, 20);
        //pauseScreenBack = new FlxButtonPlus(500, 300, backToMenu, "Exit", 100, 20);
        pauseScreenContinue = new BetterButton(120, 300, 150, 20, "Continue", 16, exitPauseMenu);
        pauseScreenBack = new BetterButton(370, 300, 150, 20, "Exit", 16, backToMenu);

        add(pauseScreenBack);

        exitPauseMenu();

        super.create();

        countdownText = new FlxText();
        countdownText.setFormat(Registry.FONT_PATH, 20);
        add(countdownText);
        resetCountdown();

        showRules = true;

        gameRulesText = new FlxText();
        gameRulesText.setFormat(Registry.FONT_PATH, 18);
        if (Registry.currentGameIndex>=0)
        {
            gameRulesText.text = Registry.gameRules[Registry.currentGameIndex];
            gameRulesText.x = (width-gameRulesText.width)/2;
            gameRulesText.y = 140;
        }
        add(gameRulesText);

        polygonHitSound = FlxG.sound.load(AssetPaths.polygonHit__wav);
        countdownBeepSound = FlxG.sound.load(AssetPaths.countdownBeep__wav, .15);
        gameStartSound = FlxG.sound.load(AssetPaths.gameStart__wav, .15);
    }

    private function enterPauseMenu():Void{
        pauseMenu = true;
        add(pauseScreenOutline);
        add(pauseScreenContinue);
        add(pauseScreenBack);
        add(pauseScreenText);
    }

    private function exitPauseMenu():Void{
        pauseMenu = false;
        remove(pauseScreenOutline);
        remove(pauseScreenContinue);
        remove(pauseScreenBack);
        remove(pauseScreenText);
    }

    private function backToMenu():Void{
        FlxG.switchState(new FinalizedMenuState());
    }

    public function resetGame():Void{
        for(obj in gameObjects)
            obj.destroy();
        for (sprite in playSprites)
            sprite.destroy();
        gameObjects = new Array<GameObject>();
        playSprites = new Array<RegularPolygonSprite>();
        velocities = new Array<Point>();
        aVelocities = new Array<Float>();
        keyLists = new Array<Array<FlxKey>>();
        resetCountdown();
    } //override to reset game

    public function declareWinner(winner:Int):Void{
        
        // handle loser
        var loser = (3-winner)-1;
        // trace(loser);
        if (_parentState == null)
        {
            Registry.currentMinigameWinner = winner;
            var playerData:Registry.PlayerData = new Registry.PlayerData(playSprites[0].x, playSprites[0].y, playSprites[0].angle,
                playSprites[1].x, playSprites[1].y, playSprites[1].angle, width, height, playSprites[0].RADIUS);
            Registry.currentPlayerData = playerData;

            openSubState(new WinnerState());
            resetGame();
            //trace("Player " + winner + " wins!");
        }
        else
        {
            Registry.currentMinigameWinner = winner;
            var playerData:Registry.PlayerData = new Registry.PlayerData(playSprites[0].x, playSprites[0].y, playSprites[0].angle,
                playSprites[1].x, playSprites[1].y, playSprites[1].angle, width, height, playSprites[0].RADIUS);
            /*_parentState.openSubState(new WinnerState(playSprites[0].x, playSprites[0].y, playSprites[0].angle,
                playSprites[1].x, playSprites[1].y, playSprites[1].angle, playSprites[0].RADIUS, width, height));*/
            
            Registry.currentPlayerData = playerData;
            _parentState.openSubState(new WinnerState());
            close();
        }
    }

    

    //// handling physics ////

    override public function update(elapsed:Float):Void
    {
        // TODO: adjust how drag works with frame rate
        super.update(elapsed);

        if (!gameStarted)
        {
            pause();
            timeToGameStart -= elapsed;
            if (!showRules)
                gameRulesText.visible = false;
            if (timeToGameStart>0)
                updateCountdownText();
            else
            {
                gameStartSound.play();
                gameStarted = true;
                countdownText.visible = false;
                gameRulesText.visible = false;
                unpause();
            }
            return;
        }

        if(FlxG.keys.anyJustPressed([ESCAPE]))
        {
            if(pauseMenu)
                exitPauseMenu();
            else
                enterPauseMenu();
        }

        if (!paused && !pauseMenu)
        {
            for(i in 0...playSprites.length)
            {    
                var sprite:RegularPolygonSprite = playSprites[i];

                if(printing || printrightnow){
                    trace(printing, printrightnow);
                    trace(velocities[i].x * 60 * elapsed, velocities[i].y * 60 * elapsed);
                    trace('before', sprite.x, sprite.y);
                }

                // apply velocities
                // sprite.x += velocities[i].x * 60 * elapsed;
                // sprite.y += velocities[i].y * 60 * elapsed;
                // sprite.center = new Point(sprite.x, sprite.y, i);
                // sprite.angle += aVelocities[i] * 60 * elapsed;
                sprite.newUpdate(elapsed, velocities[i].x, velocities[i].y, aVelocities[i]);
                sprite.update(elapsed);
                // max velocity in game is around 16. theoretical is 20
                // max angular velocity in game is around 9. theoretical is 10

                if(printing || printrightnow)
                    trace('after', sprite.x, sprite.y);
                
                // apply drags
                velocities[i].x *= (1 - (1-DRAG) * 60 * elapsed);
                velocities[i].y *= (1 - (1-DRAG) * 60 * elapsed);
                aVelocities[i] *= (1 - (1-ANGULAR_DRAG) * 60 * elapsed);

                // check key for accelerations
                if(keyLists[i].length >= 4 && !currentlyColliding){
                    if(FlxG.keys.anyPressed([keyLists[i][1]]))
                        aVelocities[i] -= ANGULAR_ACCELERATION * 60 * elapsed;
                    if(FlxG.keys.anyPressed([keyLists[i][3]]))
                        aVelocities[i] += ANGULAR_ACCELERATION * 60 * elapsed;
                    if(FlxG.keys.anyPressed([keyLists[i][0]]))
                        velocities[i].add(Point.polarPoint(ACCELERATION * 60 * elapsed, Math.PI*sprite.angle/180));
                    if(FlxG.keys.anyPressed([keyLists[i][2]]))
                        velocities[i].subtract(Point.polarPoint(ACCELERATION * 60 * elapsed, Math.PI*sprite.angle/180));
                }

                // // keep sprites within bounds
                // if(sprite.x < 0 && velocities[i].x < 0) velocities[i].x *= -1;
                // if(sprite.x > width && velocities[i].x > 0) velocities[i].x *= -1;
                // if(sprite.y < 0 && velocities[i].y < 0) velocities[i].y *= -1;
                // if(sprite.y > height && velocities[i].y > 0) velocities[i].y *= -1;

                


            }

            // trace('should be updated, not yet checking collisions');

            checkAndHandleCollisions();
            checkAndHandleBoundaryCollisions();

            // trace('         end update');

        }
    }

    private function checkAndHandleBoundaryCollisions():Void{
        var setFalse = true;

        for(i in 0...playSprites.length){
            for(j in 0...boundingBoxes.length){
                if(checkAndHandleSpriteBoundaryCollision(i, j))
                    setFalse = false;
            }
        }

        if(setFalse)
            currentlyCollidingBoundary = false;
    }

    private function checkAndHandleSpriteBoundaryCollision(a:Int, b:Int):Bool
    {
        // get A endpoints
        var playerASides:Array<EdgeSprite> = playSprites[a].members;
        var playerAEndpoints:Array<Point> = new Array<Point>();
        for (i in 0...playerASides.length)
        {
            var rect:EdgeSprite = playerASides[i];
            var radAngle:Float = rect.angle * Math.PI / 180;
            var centerX:Float = rect.x + rect.width/2;
            var centerY:Float = rect.y + rect.height/2;
            //gets the "left" endpoint of the rectangle
            playerAEndpoints.push(new Point(centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2, a));
        }

        var rect = boundingBoxes[b];
        var playerBEndPoints:Array<Point> = new Array<Point>();
        playerBEndPoints.push(new Point(rect.left, rect.top));
        playerBEndPoints.push(new Point(rect.left, rect.bottom));
        playerBEndPoints.push(new Point(rect.right, rect.bottom));
        playerBEndPoints.push(new Point(rect.right, rect.top));
        playerBEndPoints.push(new Point(rect.left, rect.top));


        for(i in 0...playerAEndpoints.length){
            for(j in 0...4){

                var p = playerAEndpoints[i];
                var p1 = playerBEndPoints[j];
                var p2 = playerBEndPoints[j+1];

                var blah = 20;
                printrightnow = (p.x < 0 + blah || p.x > width - blah || p.y < 0 + blah || p.y > height - blah);
                // trace('p', printrightnow);
                
                blah = 0;
                if(p.x < 0 + blah|| p.x > width - blah || p.y < 0 + blah || p.y > height - blah){
                    printing = true;
                }

                // TODO: check correctness of this
                if(checkCollidePointAndSegment(p, a, p1, p2, -1)){
                    // if(!currentlyCollidingBoundary){

                        // var pcoord:Float = projectiveCoordinateWithRect(p, rect);
                        // var collPoint:Point = pointAlongRectangle(rect, pcoord);
                        var collPoint = p;

                        var aCenter = playSprites[a].center;
                        var bCenter = new Point(width/2, height/2); // TODO: un-hardcode this

                        var aRad:Point = Point.minus(p, aCenter);
                        var bRad:Point = Point.minus(collPoint, bCenter);
                        var velDif:Point = Point.minus(velocities[a], velocities[b]);

                        var line = Point.minus(p2, p1);
                        var nvec = new Point(-line.y / line.magnitude(), line.x / line.magnitude());

                        
                        var diffa = Point.minus(p.rotatedCW(aCenter, aVelocities[a]), p);
                        var vap = Point.plus(velocities[a], diffa);
                        var vbp = new Point(0, 0);
                        var top = Point.dot(Point.minus(vap, vbp), nvec);
                        if(top > 0){
                            nvec = new Point(-nvec.x, -nvec.y);
                            top *= -1;
                        }
                        // nvec should point from b.edge outwards

                        var e = 1;
                        var imp = Math.abs( (1+e) * top ) / (1/1 + Math.pow(Point.cross(aRad, nvec),2) / (5.0/4 * Math.pow(playSprites[a].RADIUS, 2)));

                        applyImpulse(a, nvec, imp, aRad);








                        // // var aCenter:Point = new Point(playSprites[a].x, playSprites[a].y, a);
                        // var aCenter = playSprites[a].center;
                        // // var bCenter:Point = new Point(0.5*(rect.left + rect.right), 0.5*(rect.top + rect.bottom));

                        // var aRad:Point = Point.minus(p, aCenter);
                        // // var bRad:Point = Point.minus(p, bCenter);
                        // var velDif = velocities[a];


                        // var line = Point.minus(p2, p1);
                        // var nvec = new Point(-line.y / line.magnitude(), line.x / line.magnitude());

                        
                        // var diffa = Point.minus(p.rotatedCW(aCenter, aVelocities[a]), p);
                        // var vap = Point.plus(velocities[a], diffa);
                        // var top = Point.dot(vap, nvec);
                        // if(top > 0){
                        //     nvec = new Point(-nvec.x, -nvec.y);
                        //     top *= -1;
                        // }

                        // var e = 1;
                        // // var j = Math.abs( (1+e) * top ) / (1/1 + 1/1 + Math.pow(Point.cross(aRad, nvec),2) / (5.0/4 * Math.pow(playSprites[a].RADIUS, 2)) + Math.pow(Point.cross(bRad, nvec),2) / (5.0/4 * Math.pow(playSprites[b].RADIUS, 2)));
                        // var imp;
                        // imp = -top;

                        if(printing || printrightnow){
                            trace(p);
                            trace(aCenter);
                            trace('da', Point.minus(p, aCenter).magnitude(), aVelocities[a]);
                            trace(velocities[a]);
                        }

                        trace(nvec);
                        trace(p);
                        trace(aCenter);
                        trace('avel', aVelocities[a]);
                        // applyImpulse(a, nvec, 2*imp, aRad);
                        // trace(imp);

                        if(checkCollidePointAndSegment(p, a, p1, p2, -1))
                            trace('bad thing boundary');
                    // }

                    currentlyCollidingBoundary = true;
                    return true;

                }

            }
        }

        return false;

    }

    private function checkAndHandleCollisions():Void
    {
        currentlyColliding = (collideSpriteAPointsWithSpriteBEdges(0,1) || collideSpriteAPointsWithSpriteBEdges(1,0)) && currentlyColliding;
    }

    //this function performs collisions (i.e. it will change velocities and stuff if things collide)
    //returns: whether a collision was found
    private function collideSpriteAPointsWithSpriteBEdges(a:Int, b:Int):Bool
    {

        var superCollides:Bool = false;

        // getA endpoints
        var playerASides:Array<EdgeSprite> = playSprites[a].members.slice(1);
        // playerASides.remove(playerASides[0]); // remove the indicator
        var playerAEndpoints:Array<Point> = new Array<Point>();
        for (i in 0...playerASides.length)
        {
            var rect:EdgeSprite = playerASides[i];
            var radAngle:Float = rect.angle * Math.PI / 180;
            var centerX:Float = rect.x + rect.width/2;
            var centerY:Float = rect.y + rect.height/2;
            //gets the "left" endpoint of the rectangle
            playerAEndpoints.push(new Point(centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2, a));
        }
        
        var playerBSides:Array<EdgeSprite> = playSprites[b].members.slice(1);
        // playerBSides.remove(playerBSides[0]); // remove the indicator
        var playerBColor:FlxColor = playSprites[b].color;


        for (i in 0...playerBSides.length)
        {
            var rect:EdgeSprite = playerBSides[i];
            var collides:Bool = false;

            for (j in 0...playerASides.length)
            {
                var p = playerAEndpoints[j];
                var points = getEndpointsOfRect(rect, b);
                var p1 = points[0];
                var p2 = points[1];
                // var p1 = rect.p1;
                // var p2 = rect.p2;
                // if (checkCollidePointAndRect(p, rect, b))
                if(checkCollidePointAndSegment(p, a, p1, p2, b))
                {
                    collides = true;
                    superCollides = true;
                    // if (!currentlyColliding)
                    {

                        currentlyColliding = true;

                        var pcoord:Float = projectiveCoordinateWithRect(p, rect);
                        var collPoint:Point = pointAlongRectangle(rect, pcoord);

                        // var aCenter:Point = new Point(playSprites[a].x, playSprites[a].y, a);
                        // var bCenter:Point = new Point(playSprites[b].x, playSprites[b].y, b);
                        var aCenter = playSprites[a].center;
                        var bCenter = playSprites[b].center;

                        var aRad:Point = Point.minus(p, aCenter);
                        var bRad:Point = Point.minus(collPoint, bCenter);
                        var velDif:Point = Point.minus(velocities[a], velocities[b]);

                        // var radAngle:Float = rect.angle * Math.PI / 180;
                        // var centerX:Float = rect.x + rect.width/2;
                        // var centerY:Float = rect.y + rect.height/2;

                        // var p1 = new Point(centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2, b);
                        // var p2 = new Point(centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2, b);
                        var line = Point.minus(p2, p1);
                        var nvec = new Point(-line.y / line.magnitude(), line.x / line.magnitude());

                        
                        var diffa = Point.minus(p.rotatedCW(aCenter, aVelocities[a]), p);
                        var vap = Point.plus(velocities[a], diffa);
                        var diffb = Point.minus(p.rotatedCW(bCenter, aVelocities[b]), p);
                        var vbp = Point.plus(velocities[b], diffb);
                        var top = Point.dot(Point.minus(vap, vbp), nvec);
                        if(top > 0){
                            nvec = new Point(-nvec.x, -nvec.y);
                            top *= -1;
                        }
                        // nvec should point from b.edge outwards

                        var e = 1;
                        var j = Math.abs( (1+e) * top ) / (1/1 + 1/1 + Math.pow(Point.cross(aRad, nvec),2) / (5.0/4 * Math.pow(playSprites[a].RADIUS, 2)) + Math.pow(Point.cross(bRad, nvec),2) / (5.0/4 * Math.pow(playSprites[b].RADIUS, 2)));

                        // http://gamedevelopment.tutsplus.com/tutorials/how-to-create-a-custom-2d-physics-engine-oriented-rigid-bodies--gamedev-8032
                        // http://chrishecker.com/images/e/e7/Gdmphys3.pdf

                        // var totalBefore = getKineticEnergy(a) + getKineticEnergy(b);

                        applyImpulse(a, nvec, j, aRad);
                        // applyImpulse(b, new Point(-nvec.x, -nvec.y), -j, bRad);
                        applyImpulse(b, nvec, -j, new Point(-bRad.x, -bRad.y));

                        // var totalAfter = getKineticEnergy(a) + getKineticEnergy(b);

                        // trace('kinetic energy', totalBefore, totalAfter);

                        polygonHitSound.play();

                        if(checkCollidePointAndSegment(p, a, p1, p2, b))
                            trace('bad thing interpolygon');
                    }
                    break;
                }
            }
            rect.color = collides ? FlxColor.RED : playerBColor;
        }

        return superCollides;

    }

    private function getKineticEnergy(i:Int):Float
    {        
        // translational
        var trans = 0.5 * Math.pow(velocities[i].magnitude(), 2);

        // rotational
        var rot = 0.5 * 5 / 4 * Math.pow(playSprites[i].RADIUS * aVelocities[i] * Math.PI / 180.0, 2);

        // trace(i, trans, rot, trans+rot);
        return trans + rot;

    }

    // private function checkCollidePointAndRect(p:Point, rect:FlxSprite, rectIndex:Int){
    //     var radAngle:Float = rect.angle * Math.PI / 180;
    //     var centerX:Float = rect.x + rect.width/2;
    //     var centerY:Float = rect.y + rect.height/2;

    //     var p1 = new Point(centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2, rectIndex);
    //     var p2 = new Point(centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2, rectIndex);
    //     return checkCollidePointAndSegment(p, p1, p2);
    // }

    private function getEndpointsOfRect(rect:EdgeSprite, rectIndex:Int){
        var radAngle:Float = rect.angle * Math.PI / 180;
        var centerX:Float = rect.x + rect.width/2;
        var centerY:Float = rect.y + rect.height/2;

        var p1 = new Point(centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2, rectIndex);
        var p2 = new Point(centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2, rectIndex);

        var points = new Array<Point>();
        points.push(p1);
        points.push(p2);
        return points;
    }

    private function checkCollidePointAndSegment(p:Point, a:Int, p1:Point, p2:Point, b:Int):Bool{
        
        var currd = getDiscriminant(p, p1, p2);

        var newp = getUpdatedPoint(p, a);
        var newp1 = getUpdatedPoint(p1, b);
        var newp2 = getUpdatedPoint(p2, b);
        var newd = getDiscriminant(newp, newp1, newp2);

        var tolDiscrim = 0;
        if(currd * newd > 0 + tolDiscrim)
            return false;
        else if(Math.abs(currd*newd) < 1){
            // trace(currd*newd);
        }

        var dif:Point = Point.minus(newp2, newp1);

        var onSegment = Point.dot(Point.minus(newp, newp1), dif) / Point.dot(dif, dif);
        // var tolerance = 0.07;
        // var tolerancePix = 7;
        var tolerancePix = 0;
        var osval = (Math.abs(onSegment - 0.5) - 0.5);
        if(osval * dif.magnitude() < tolerancePix){
            return true;
        }
        // if(osval < 0.1){
        //     trace(osval, dif.magnitude());
        // }
        // trace(osval);
        // if(onSegment >= 0-tolerance && onSegment <= 1+tolerance){
        //     return true;
        // }

        return false;
    }

    private function applyImpulse(ind:Int, n:Point, j:Float, rad:Point){
        aVelocities[ind] += j * 180.0/Math.PI / (5.0/4 * Math.pow(playSprites[ind].RADIUS, 2)) * Point.cross(rad, n);
        var velChange = new Point(n.x * j, n.y * j);
        velocities[ind] = Point.plus(velocities[ind], velChange);
    }


    private static function distanceFromPointToSegment(x:Float, y:Float, a1:Float, b1:Float, a2:Float, b2:Float):Float{
        return((x - a1) * (b2 - b1) + (b1 - y) * (a2-a1))/Math.sqrt((b2-b1)*(b2-b1) + (a2-a1)*(a2-a1)); //wikipedia to the rescue
    }

    private static function distanceFromPointToRectLine(p:Point, rect:FlxSprite){
        var radAngle:Float = rect.angle * Math.PI / 180;
        var centerX:Float = rect.x + rect.width/2;
        var centerY:Float = rect.y + rect.height/2;
        return distanceFromPointToSegment(p.x, p.y, centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2,
            centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2);
    }

    private static function distanceFromPointToRect(p:Point, rect:FlxSprite):Float{
        var projCoord = projectiveCoordinateWithRect(p, rect);
        var radAngle:Float = rect.angle * Math.PI / 180;
        var centerX:Float = rect.x + rect.width/2;
        var centerY:Float = rect.y + rect.height/2;
        var nearSide:Point = new Point(centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2);
        var farSide:Point = new Point(centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2);
        if(projCoord > 0 && projCoord < 1)
            return Math.abs(distanceFromPointToSegment(p.x, p.y, nearSide.x, nearSide.y, farSide.x, farSide.y));
        var nearSideDif = Point.minus(p, nearSide);
        var farSideDif = Point.minus(p, farSide);
        return Math.min(Math.sqrt(Point.dot(nearSideDif,nearSideDif)), Math.sqrt(Point.dot(farSideDif,farSideDif)));
    }

    private static function projectiveCoordinate(x:Float, y:Float, a1:Float, b1:Float, a2:Float, b2:Float):Float{
        return ((x-a1)*(a2-a1) + (y-b1)*(b2-b1))/((b2-b1)*(b2-b1) + (a2-a1)*(a2-a1));
    }

    private static function projectiveCoordinateWithRect(p:Point, rect:FlxSprite){
        var radAngle:Float = rect.angle * Math.PI / 180;
        var centerX:Float = rect.x + rect.width/2;
        var centerY:Float = rect.y + rect.height/2;
        return projectiveCoordinate(p.x, p.y, centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2,
            centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2);
    }

    private static function averageOfPoints(p1:Point, p2:Point, alpha:Float = 0.5):Point{
        return new Point(p1.x * alpha + p2.x * (1-alpha), p1.y * alpha + p2.y * (1-alpha), p1.polyInd);
    }

    private static function pointAlongRectangle(rect:FlxSprite, alpha:Float = 0.5):Point{
        var radAngle:Float = rect.angle * Math.PI/180;
        return averageOfPoints(new Point(rect.x + rect.width/2 - rect.width*Math.cos(radAngle)/2, rect.y + rect.height/2 - rect.width*Math.sin(radAngle)/2,-1),
            new Point(rect.x + rect.width/2 + rect.width*Math.cos(radAngle)/2, rect.y + rect.height/2 + rect.width*Math.sin(radAngle)/2,-1), alpha);
    }

    private static function getDiscriminant(p:Point, p1:Point, p2:Point):Float{
        // trace(p);
        // trace(p1);
        // trace(p2);
        // standard form ax + by = c defines the line
        // discriminant determines which side point p is on of line segment p1-p2
        var a = p2.y - p1.y;
        var b = p1.x - p2.x;
        var c = a*p1.x + b*p1.y;

        return a*p.x + b*p.y - c;
    }

    private function getUpdatedPoint(p:Point, i:Int):Point{
        var numFrames = 1.5;

        if(i < 0){
            // trace('wtf');
            return p;
        }

        // update by velocity
        var newp:Point = Point.plus(p, velocities[i].scale(numFrames));
        newp.polyInd = i;

        // update by rotation
        // var origin = new Point(playSprites[i].x, playSprites[i].y, i);
        var origin = playSprites[i].center;
        return newp.rotatedCW(origin, numFrames*aVelocities[i]);
    }

    

    public function resetCountdown():Void
    {
        countdownText.visible = true;
        timeToGameStart = 3;
        gameStarted = false;
    }

    public function updateCountdownText():Void
    {
        var newText:String = Std.string(Math.ceil(timeToGameStart));
        if (countdownText.text != newText)
        {
            countdownBeepSound.play();
        }
        countdownText.text = newText;
        countdownText.x = (width-countdownText.width)/2;
        countdownText.y = (height-countdownText.height)/2-50;
    }

    public function pause():Void
    {
        paused = true;
    }

    public function unpause():Void
    {
        paused = false;
    }

}