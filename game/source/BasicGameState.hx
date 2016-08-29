package;

import flixel.addons.display.FlxNestedSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

class BasicGameState extends FlxState
{
    var playSprites:Array<NewPolygonSprite>;
    var velocities:Array<Point>;
    var aVelocities:Array<Float>;
    var keyLists:Array<Array<FlxKey>>;

    var width:Float;
    var height:Float;

    var currentlyColliding:Bool;

    var paused:Bool;

    public static inline var ACCELERATION:Float = 0.2;
    public static inline var ANGULAR_ACCELERATION:Float = 0.4;
    public static inline var ANGULAR_DRAG:Float = 0.96;
    public static inline var ANGULAR_VELOCITY:Float = 5;
    public static inline var VELOCITY:Float = 4;
    public static inline var DRAG:Float = 0.99;
    public static inline var ELASTICITY:Float = .90;
    public static inline var ANGULAR_RECOIL:Float = -0.01;
    public static inline var COLLISION_THRESHOLD:Float = 10;

    public function makeSprite(sprite:NewPolygonSprite, keymap:Array<FlxKey>, xv:Float = 0, yv:Float = 0, av:Float = 0):Int
    {
        playSprites.push(sprite);
        keyLists.push(keymap);
        velocities.push(new Point(xv, yv, -1));
        aVelocities.push(av);
        add(sprite);
        return playSprites.length - 1;
    }
    
    override public function create():Void
    {
        width = FlxG.width;
        height = FlxG.height;

        playSprites = new Array<NewPolygonSprite>();
        velocities = new Array<Point>();
        aVelocities = new Array<Float>();
        keyLists = new Array<Array<FlxKey>>();
        
        currentlyColliding = false;
        paused = false;

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        // TODO: adjust how drag works with frame rate

        // trace("begin state update");

        super.update(elapsed);

        if (!paused)
        {
            for(i in 0...playSprites.length)
            {    
                var sprite:NewPolygonSprite = playSprites[i];

                // apply velocities
                sprite.x += velocities[i].x * 60 * elapsed;
                sprite.y += velocities[i].y * 60 * elapsed;
                sprite.angle += aVelocities[i] * 60 * elapsed;
                // max velocity in game is around 16. theoretical is 20
                // max angular velocity in game is around 9. theoretical is 10
                
                // apply drags
                velocities[i].x *= DRAG;
                velocities[i].y *= DRAG;
                aVelocities[i] *= ANGULAR_DRAG;

                // check key for accelerations
                if(keyLists[i].length >= 4 && !currentlyColliding){
                    if(FlxG.keys.anyPressed([keyLists[i][1]])) aVelocities[i] -= ANGULAR_ACCELERATION * 60 * elapsed;
                    if(FlxG.keys.anyPressed([keyLists[i][3]])) aVelocities[i] += ANGULAR_ACCELERATION * 60 * elapsed;
                    if(FlxG.keys.anyPressed([keyLists[i][0]]))
                        velocities[i].add(Point.polarPoint(ACCELERATION * 60 * elapsed, Math.PI*sprite.angle/180));
                    if(FlxG.keys.anyPressed([keyLists[i][2]]))
                        velocities[i].subtract(Point.polarPoint(ACCELERATION * 60 * elapsed, Math.PI*sprite.angle/180));
                }

                // keep sprites within bounds
                if(sprite.x < 0 && velocities[i].x < 0) velocities[i].x *= -1;
                if(sprite.x > width && velocities[i].x > 0) velocities[i].x *= -1;
                if(sprite.y < 0 && velocities[i].y < 0) velocities[i].y *= -1;
                if(sprite.y > height && velocities[i].y > 0) velocities[i].y *= -1;

            }
            checkCollisions();
        }
        //checkCollisionsWithPoints();
    }

    private function checkCollisions():Void
    {
        // var setCurrentlyCollidingFalse = true;

     //    var collided:Bool = collideSpriteAPointsWithSpriteBEdges(0,1);
     //    if(collided)
     //     setCurrentlyCollidingFalse = false;

     //    var collided2:Bool = collideSpriteAPointsWithSpriteBEdges(1,0);
     //    if(collided2)
     //     setCurrentlyCollidingFalse = false;

     //    if(setCurrentlyCollidingFalse)
     //     currentlyColliding = false;

        currentlyColliding = (collideSpriteAPointsWithSpriteBEdges(0,1) || collideSpriteAPointsWithSpriteBEdges(1,0)) && currentlyColliding;
    }

    //this function performs collisions (i.e. it will change velocities and stuff if things collide)
    //returns: whether a collision was found
    private function collideSpriteAPointsWithSpriteBEdges(a:Int, b:Int):Bool
    {
        
        var playerASides:Array<FlxSprite> = playSprites[a].members;
        var playerBSides:Array<FlxSprite> = playSprites[b].members;
        var playerBColor:FlxColor = playSprites[b].color;
        // get A endppoints
        var playerAEndpoints:Array<Point> = new Array<Point>();
        for (i in 0...playerASides.length)
        {
            var rect:FlxSprite = playerASides[i];
            var radAngle:Float = rect.angle * Math.PI / 180;
            var centerX:Float = rect.x + rect.width/2;
            var centerY:Float = rect.y + rect.height/2;
            //gets the "left" endpoint of the rectangle
            playerAEndpoints.push(new Point(centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2, a));
        }

        var superCollides:Bool = false;

        for (i in 0...playerBSides.length)
        {
            var rect:FlxSprite = playerBSides[i];
            var collides:Bool = false;

            for (j in 0...playerASides.length)
            {
                // if (checkCollidePointAndRect(playerAEndpointsX[j], playerAEndpointsY[j], rect))
                var p = playerAEndpoints[j];
                if (checkCollidePointAndRect(p, rect, b))
                {
                    collides = true;
                    superCollides = true;
                    if (!currentlyColliding)
                    {
                        currentlyColliding = true;

                        var pcoord:Float = projectiveCoordinateWithRect(p, rect);
                        var collPoint:Point = pointAlongRectangle(rect, pcoord);

                        var aCenter:Point = new Point(playSprites[a].x, playSprites[a].y, a);
                        var bCenter:Point = new Point(playSprites[b].x, playSprites[b].y, b);

                        var aRad:Point = Point.minus(p, aCenter);
                        var bRad:Point = Point.minus(collPoint, bCenter);
                        var velDif:Point = Point.minus(velocities[a], velocities[b]);

                        // var total = -Point.cross(velDif, aRad) + Point.cross(velDif, bRad);
                        // trace(total);
                        // var dwa = total / (2.0 * (5.0/4 * Math.pow(playSprites[a].RADIUS, 2)));
                        // var dwb = total / (2.0 * (5.0/4 * Math.pow(playSprites[b].RADIUS, 2)));
                        // trace(dwa, dwb);

                        // aVelocities[a] -= dwa;
                        // aVelocities[b] -= dwb;

                        var radAngle:Float = rect.angle * Math.PI / 180;
                        var centerX:Float = rect.x + rect.width/2;
                        var centerY:Float = rect.y + rect.height/2;

                        var p1 = new Point(centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2, b);
                        var p2 = new Point(centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2, b);
                        var line = Point.minus(p2, p1);
                        var nvec = new Point(-line.y / line.magnitude(), line.x / line.magnitude());

                        var top = Point.dot(Point.minus(aCenter, bCenter), nvec);
                        if(top > 0){
                            nvec = new Point(-nvec.x, -nvec.y);
                            top *= -1;
                        }
                        // nvec should point from b.edge outwards

                        var e = 1;
                        var j = Math.abs( (1+e) * top ) / (1/1 + 1/1 + Math.pow(Point.cross(aRad, nvec),2) / (5.0/4 * Math.pow(playSprites[a].RADIUS, 2)) + Math.pow(Point.cross(bRad, nvec),2) / (5.0/4 * Math.pow(playSprites[b].RADIUS, 2)));

                        applyImpulse(a, nvec, -j, aRad);
                        // applyImpulse(b, new Point(-nvec.x, -nvec.y), -j, bRad);
                        applyImpulse(b, nvec, j, new Point(-bRad.x, -bRad.y));

                        trace(j);


                        // var totalL = Point.cross(velDif, aRad) + 0 * (5.0/4 * Math.pow(playSprites[a].RADIUS, 2));
                        // var idwb = -totalL + Point.cross(velDif, bRad);
                        // var dwb = idwb / (5.0/4 * Math.pow(playSprites[b].RADIUS, 2));
                        // aVelocities[b] -= dwb;

                        // var oldAngVelocityA = aVelocities[a];
                        // aVelocities[a] = - aVelocities[b];
                        // aVelocities[b] = -oldAngVelocityA;
                        // aVelocities[a] += Point.cross(velDif, aRad)*ANGULAR_RECOIL;
                        // aVelocities[b] -= Point.cross(velDif, bRad)*ANGULAR_RECOIL;
                        // var aCenter = new Point(playSprites[a].x, playSprites[a].y, a);
                        // var bCenter = new Point(playSprites[b].x, playSprites[b].y, b);
                        // var r = Point.minus(bCenter, aCenter);
                        // var d = r.magnitude();

                        // //velDif = v1 - v2

                        // var idw1 = (5.0/4 * Math.pow(playSprites[b].RADIUS, 2) + Math.pow(d, 2)) * Point.cross(velDif, r) / d;
                        // var dw1 = idw1 / (5.0/4 * Math.pow(playSprites[a].RADIUS, 2));
                        // aVelocities[a] -= dw1;

                        // var idw2 = (5.0/4 * Math.pow(playSprites[a].RADIUS, 2) + Math.pow(d, 2)) * Point.cross(velDif, r) / d;
                        // var dw2 = idw2 / (5.0/4 * Math.pow(playSprites[a].RADIUS, 2));
                        // aVelocities[b] -= dw2;

                        
                                        // VELOCITY SWAP
                        // var tmp:Point = velocities[0];
                        // velocities[0] = velocities[1];
                        // velocities[1] = tmp;

                    }
                    break;
                }
            }
            rect.color = collides ? FlxColor.RED : playerBColor;
        }

        return superCollides;

    }

    private function applyImpulse(ind:Int, n:Point, j:Float, rad:Point){
        trace("     ", aVelocities[ind]);
        aVelocities[ind] += j / (5.0/4 * Math.pow(playSprites[ind].RADIUS, 2)) * Point.cross(rad, n);
        trace(ind, j / (5.0/4 * Math.pow(playSprites[ind].RADIUS, 2)) * Point.cross(rad, n));

        var velChange = new Point(n.x * j * Math.PI / 180.0, n.y * j * Math.PI / 180.0);
        velocities[ind] = Point.plus(velocities[ind], velChange);
        trace(velChange.x, velChange.y);
        trace(velocities[ind]);

    }

    // private static function checkCollidePointAndSegment(x:Float, y:Float, a1:Float, b1:Float, a2:Float, b2:Float):Bool{
    //  var dist:Float = Math.abs(((x - a1) * (b2 - b1) + (b1 - y) * (a2-a1)))/Math.sqrt((b2-b1)*(b2-b1) + (a2-a1)*(a2-a1)); //wikipedia to the rescue
    //  var projectionCoord:Float = ((x-a1)*(a2-a1) + (y-b1)*(b2-b1))/((b2-b1)*(b2-b1) + (a2-a1)*(a2-a1));
    //  if(dist < COLLISION_THRESHOLD){
    //      if(projectionCoord >= 0 && projectionCoord <= 1){
    //          trace(dist + " " + projectionCoord + "\n");
    //          return true;
    //      }
    //  }
    //  return false;
    // }

    private function checkCollidePointAndSegment(p:Point, p1:Point, p2:Point):Bool{
        
        var currd = getDiscriminant(p, p1, p2);

        var newp = getUpdatedPoint(p);
        var newp1 = getUpdatedPoint(p1);
        var newp2 = getUpdatedPoint(p2);
        var newd = getDiscriminant(newp, newp1, newp2);

        //if(aVelocities[1] > 5){
            //trace('begin');
            //trace(aVelocities[1]);
            // trace(distanceFromPointToSegment(p.x, p.y, p1.x, p1.y, p2.x, p2.y));
            //trace(currd, newd);
            //trace(p.x, p.y);
            //trace(newp.x, newp.y);
            // trace(p1.x, p1.y);
            // trace(p2.x, p2.y);
            // trace(newp1.x, newp1.y);
            // trace(newp2.x, newp2.y);
        //}

        if(currd * newd > 0)
            return false;

        var dif:Point = Point.minus(p2, p1);

        var onSegment = Point.dot(Point.minus(p, p1), dif) / Point.dot(dif, dif);
        if(onSegment >= 0 && onSegment <= 1){
            
            // 1088.11037239469,-155.058256960268,0.658473061964883
            // 7.30366411013711,123.808197889638 p
            // 7.30366411013711,123.808197889638 newp
            // -26.2886253361309,549.261153634737 p1
            // -10.1313151170315,377.017310997377 p2
            // -33.2027749734581,546.027389688666 newp1
            // -17.0454647543587,373.783547051305 newp2

            // (7.30366411013711 - -26.2886253361309) * (-10.1313151170315 - -26.2886253361309) + (123.808197889638 - 549.261153634737) * (377.017310997377 - 549.261153634737)
            // (-10.1313151170315 - -26.2886253361309) * (-10.1313151170315 - -26.2886253361309) + (377.017310997377 - 549.261153634737) * (377.017310997377 - 549.261153634737)
            // 73824.4130005
            // 29929
            // onSegment should be 2.46665150859


            return true;
        }

        return false;
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

    // private static function checkCollidePointAndSegment(x:Float, y:Float, a1:Float, b1:Float, a2:Float, b2:Float):Bool{
    //  var dist:Float = Math.abs(distanceFromPointToSegment(x,y,a1,b1,a2,b2)); //wikipedia to the rescue
    //  var projectionCoord:Float = projectiveCoordinate(x,y,a1,b1,a2,b2);
    //  return (dist < COLLISION_THRESHOLD) && (projectionCoord >= 0) && (projectionCoord <= 1);
    // }

    private static function getDiscriminant(p:Point, p1:Point, p2:Point):Float{
        var a = p2.y - p1.y;
        var b = p1.x - p2.x;
        var c = a*p1.x + b*p1.y;

        return a*p.x + b*p.y - c;
    }

    private function getUpdatedPoint(p:Point):Point{

        var i = p.polyInd;

        // update by velocity
        var newp:Point = Point.plus(p, velocities[i]);
        newp.polyInd = i;

        // update by rotation
        var origin = new Point(playSprites[i].x, playSprites[i].y, i);
        return newp.rotatedCW(origin, aVelocities[i]);
    }

    // private static function checkCollidePointAndRect(x:Float, y:Float, rect:FlxSprite){
    //  var radAngle:Float = rect.angle * Math.PI / 180;
    //  var centerX:Float = rect.x + rect.width/2;
    //  var centerY:Float = rect.y + rect.height/2;
    //  return checkCollidePointAndSegment(x, y, centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2,
    //      centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2);
    // }

    private function checkCollidePointAndRect(p:Point, rect:FlxSprite, rectIndex:Int){
        var radAngle:Float = rect.angle * Math.PI / 180;
        var centerX:Float = rect.x + rect.width/2;
        var centerY:Float = rect.y + rect.height/2;

        var p1 = new Point(centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2, rectIndex);
        var p2 = new Point(centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2, rectIndex);
        return checkCollidePointAndSegment(p, p1, p2);
    }

    public function pause():Void
    {
        paused = true;
    }

    public function unpause():Void
    {
        paused = false;
    }

    // private function checkCollisionsWithPoints():Void
    // {
    //  var player1Segments:Array<FlxSprite> = playSprites[0].members;
    //  for(rect in player1Segments)
    //  {
    //      rect.color = checkCollidePointAndRect(640/2, 480/2, rect) ? FlxColor.BLUE : FlxColor.WHITE;
    //  }
    // }
    
/* This was old checkCollisions code that used pixelPerfectOverlap
    private function checkCollisions():Void
    {
        var player1Segments:Array<FlxSprite> = playSprites[0].members;
        var player2Segments:Array<FlxSprite> = playSprites[1].members;
        
        var superCollides = false;
        for (i in 0...player1Segments.length)
        {
            var segment1 = player1Segments[i];
            var collides = false;

            for (j in 0...player2Segments.length)
            {
                var segment2 = player2Segments[j];
                if (FlxG.pixelPerfectOverlap(segment1, segment2))
                {
                    collides = true;
                    superCollides = true;
                    if (!currentlyColliding)
                    {
                        currentlyColliding = true;
                        var tmp:Float = xVelocities[0];
                        xVelocities[0] = xVelocities[1];
                        xVelocities[1] = tmp;

                        tmp = yVelocities[0];
                        yVelocities[0] = yVelocities[1];
                        yVelocities[1] = tmp;
                    }
                    break;
                }   
            }
            segment1.color = collides ? FlxColor.RED : FlxColor.WHITE;
        }
        if (!superCollides)
        {
            currentlyColliding = false;
        }
    }
*/
}