/*
    This file is part of Ladylike's source.

    Ladylike's source is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Ladylike's source is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Ladylike's source. If not, see <http://www.gnu.org/licenses/>.
*/

package
{
    import org.flixel.*;

    public class GroceryState extends PlayerState{
        [Embed(source = '../assets/Market.png')] public static var spriteBG:Class;
        [Embed(source = '../assets/eggshatter.mp3')] public static var soundEgg:Class;
        [Embed(source = '../assets/freezerloop.mp3')] public static var soundBG:Class;

        public var eggs:Array;
        public var timerText:FlxText;
        public var lost:Boolean = false;
        public var timeLimit:int = 4;
        public var timeLose:int = -1;
        public var timeGrab:int = -1;
        public var soundLock:Boolean = false;

        override public function create():void{
            super._create(true, false);
            makeGround();

            var bg:FlxSprite = new FlxSprite(0, 0, spriteBG);
            add(bg);

            var instruction:FlxSprite = new FlxText(220,5,100,"Arrows to grab some eggs and bring them to mom");
            instruction.color = 0xFF666699;
            FlxG.state.add(instruction);

            timerText = new FlxText(50,10,100,"");
            timerText.color = 0xFF666699;
            add(timerText);

            makePlayer();
            player.x = 20;
            player.runFast = true;

            eggs = new Array(1);
            for(var i:int = 0; i < eggs.length; i++){
                var egg:Egg = new Egg(-1870, 170);
                add(egg);
                eggs[i] = egg;
            }

            FlxG.playMusic(soundBG);
        }

        override public function update():void{
            super.update();
            FlxG.collide(player, ground, handleGround);

            var i:int;

            if(timeLose != -1 && timeSec - timeLose >= 2) {
                FlxG.switchState(new TextState("Sorry mom...", new EndState("You need to be more careful.\nI'm sending you back to gymnastics to practice your balance.")));
            }

            if(timeSec == 5){
                if(player.holding == true) {
                    timerText.text = "I have to hurry or mom will be so mad!";
                } else {
                    timerText.text = "Mom wants eggs...";
                }
            }

            if(!lost && player.holding && player.isMoving && timeGrab != -1 && timeFrame - timeGrab > 70){
                timeLose = timeSec;
                timerText.text = "";
                lost = true;
                player.no_control = true;
                player.fallen = true;
                if (!soundLock) {
                    soundLock = true;
                    FlxG.play(soundEgg);
                    player.play("falling");
                    for(i = 0; i < eggs.length; i++){
                        if (eggs[i].held) {
                            eggs[i].play("break");
                        }
                    }
                }
            }

            if (player.grabbing && player.x < 210) {
                timeGrab = timeFrame;
                for(i = 0; i < eggs.length; i++){
                    player.holding = true;
                    eggs[i].held = true;
                }
            }

            for(i = 0; i < eggs.length; i++){
                if (eggs[i].held == true){
                    eggs[i].x = player.x+5;
                    eggs[i].y = player.y+10;
                }
            }
        }
    }
}
