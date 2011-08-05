package com.thegoldenmule.einsteindemo;
import com.thegoldenmule.einstein.EPoint;
import com.thegoldenmule.einstein.Observer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.text.TextField;

/**
 * ...
 * @author thegoldenmule
 */

class ContextMenu extends Sprite {
	
	private var _referenceFrame:Observer;
	private var _observer:Observer;
	private var _axes:Sprite;
	private var _info:TextField;
	private var _button:Sprite;
	
	public function new() {
		super();
		
		_observer = null;
		
		_axes = new Sprite();
		addChild(_axes);
		
		_button = new Sprite();
		_button.graphics.beginFill(0x990099);
		_button.graphics.drawRect(0, 0, 80, 20);
		_button.graphics.endFill();
		_button.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
		addChild(_button);
		
		_info = new TextField();
		_info.textColor = 0x76EE00;
		_info.y = _button.height + 10;
		_info.height = Lib.current.stage.stageHeight - _info.y;
		_info.width = 200;
		_info.mouseEnabled = false;
		addChild(_info);
		
		addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
	}
	
	public function startTracking(referenceFrame:Observer, observer:Observer):Void {
		stopTracking();
		
		_referenceFrame = referenceFrame;
		_observer = observer;
		
		_observer.selected = true;
	}
	
	public function stopTracking():Void {
		if (null != _observer) _observer.selected = false;
		_observer = _referenceFrame = null;
		
		if (null != parent) parent.removeChild(this);
	}
	
	private function enterFrameHandler(event:Event):Void {
		if (null == _observer) return;
		
		var vel:EPoint = _observer.velocity;
		var pos:EPoint = _observer.position;
		var rot:Float = _observer.rotation;
		
		var time:Float = _observer.time;
		var hundredths:String = Std.string(Std.int(time % 1000));
		var seconds:String = Std.string(Std.int(time / 1000));
		var minutes:String = Std.string(Std.int(time / 1000 / 60));
		
		var info:String =
			"Velocity:\t(" + Std.string(vel.x).substr(0, 5) + "c, " + Std.string(vel.y).substr(0, 5) + "c)" +
			"\nPosition:\t(" + Std.string(pos.x).substr(0, 5) + ", " + Std.string(pos.y).substr(0, 5) + ")" +
			"\nRotation:\t" + Std.string(rot).substr(0, 4) +
			"\nTime:\t\t" + minutes + ":" + seconds + ":" + hundredths;
		
		_info.text = info;
	}
	
	private function clickHandler(event:MouseEvent):Void {
		dispatchEvent(new ContextMenuEvent(ContextMenuEvent.SWITCH_REFERENCE_FRAMES, _observer));
	}
}