package com.thegoldenmule;

import com.thegoldenmule.einstein.Integrator;
import com.thegoldenmule.einstein.TimeEvent;
import com.thegoldenmule.einsteindemo.ContextMenu;
import com.thegoldenmule.einstein.EPoint;
import com.thegoldenmule.einstein.Observer;
import com.thegoldenmule.einstein.Universe;
import com.thegoldenmule.einsteindemo.ContextMenuEvent;
import com.thegoldenmule.logging.SOSTrace;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.text.TextField;
import net.hires.debug.Stats;

/**
 * ...
 * @author thegoldenmule
 */

class Main {
	
	private static var _universe:Universe;
	private static var _menu:ContextMenu;
	private static var _display:TextField;
	private static var _button:Sprite;
	private static var _button2:Sprite;
	private static var _container:Sprite;
	
	static function main() {
		init();
	}
	
	private static function init():Void {
		// logging
		new SOSTrace();
		
		// stats
		Lib.current.addChild(new Stats());
		
		// container for observers
		_container = new Sprite();
		
		// menu
		_menu = new ContextMenu();
		_menu.y = 100;
		_menu.addEventListener(ContextMenuEvent.SWITCH_REFERENCE_FRAMES, switchReferenceFrameHandler, false, 0, true);
		
		// create universe
		_universe = new Universe();
		
		// create observers
		createObservers();
		
		// add label
		_display = new TextField();
		_display.textColor = 0xAAAAAA;
		_display.text = "Relativistic";
		_display.width = 75;
		_display.x = Lib.current.stage.stageWidth - _display.width;
		_display.mouseEnabled = false;
		Lib.current.addChild(_display);
		
		// add buttons
		_button = new Sprite();
		_button.graphics.beginFill(0x990000);
		_button.graphics.drawRect(0, 0, 100, 30);
		_button.graphics.endFill();
		var textfield:TextField = new TextField();
		textfield.textColor = 0xFFFFFF;
		textfield.text = "New Observers";
		textfield.width = textfield.textWidth + 6;
		textfield.x = _button.width / 2 - textfield.width / 2;
		textfield.mouseEnabled = false;
		_button.addChild(textfield);
		_button.x = Lib.current.stage.stageWidth - _button.width;
		_button.y = Lib.current.stage.stageHeight - 30;
		_button.addEventListener(MouseEvent.CLICK, buttonClickHandler, false, 0, true);
		Lib.current.addChild(_button);
		
		_button2 = new Sprite();
		_button2.graphics.beginFill(0x009900);
		_button2.graphics.drawRect(0, 0, 100, 30);
		_button2.graphics.endFill();
		textfield = new TextField();
		textfield.textColor = 0xFFFFFF;
		textfield.text = "Transform";
		textfield.width = textfield.textWidth + 6;
		textfield.x = _button2.width / 2 - textfield.width / 2;
		textfield.mouseEnabled = false;
		_button2.addChild(textfield);
		_button2.x = Lib.current.stage.stageWidth - 2 * _button2.width - 10;
		_button2.y = Lib.current.stage.stageHeight - 30;
		_button2.addEventListener(MouseEvent.CLICK, button2ClickHandler, false, 0, true);
		Lib.current.addChild(_button2);
		
		// add container
		Lib.current.addChild(_container);
		
		// listen + start big bang
		_universe.addEventListener(TimeEvent.TICK, render, false, 0, true);
		_universe.start();
	}
	
	private static function render(event:TimeEvent):Void {
		// render each observer
		var observer:Observer;
		var observers:Array<Observer> = _universe.observers;
		for (observer in observers) {
			observer.debugRender();
		}
	}
	
	private static function createObservers():Void {
		var observer:Observer;
		
		// remove old observers
		var observers:Array<Observer> = _universe.observers;
		for (observer in observers) {
			observer.view.parent.removeChild(observer.view);
		}
		
		// create reference frame
		var referenceFrame:Observer = new Observer();
		referenceFrame.debugRender();
		referenceFrame.view.x = Lib.current.stage.stageWidth / 2 - referenceFrame.view.width / 2;
		referenceFrame.view.y = Lib.current.stage.stageHeight / 2 - referenceFrame.view.height / 2;
		referenceFrame.view.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
		_container.addChild(referenceFrame.view);
		_universe.referenceFrame = referenceFrame;
		
		// create some observers
		var i:Int = 0;
		for (i in 0...100) {
			observer = new Observer();
			
			// assign a random position relative to the reference frame
			observer.position.x = Math.random() * i * 25;
			observer.position.y = Math.random() * i * 10;
			
			// assign a random velocity relative to the reference frame
			observer.velocity.x = 2 * Math.random() - 1;
			observer.velocity.y = 2 * Math.random() - 1;
			
			// assign a random rotation relative to the reference frame
			observer.rotation = Math.random() * 90 * Math.PI / 180;
			
			// listen for clicks to display menu
			observer.view.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			
			// add to our universe
			_universe.addObserver(observer);
		}
	}
	
	private static function buttonClickHandler(event:MouseEvent):Void {
		_menu.stopTracking();
		
		createObservers();
	}
	
	private static function button2ClickHandler(event:MouseEvent):Void {
		var classic:Bool = false;
		var observer:Observer = null;
		var observers:Array<Observer> = _universe.observers;
		for (observer in observers) {
			observer.applyLorentzTransform = !observer.applyLorentzTransform;
			classic = !observer.applyLorentzTransform;
		}
		
		_display.text = classic ? "Classical" : "Relativistic";
	}
	
	private static function clickHandler(event:MouseEvent):Void {
		_menu.startTracking(_universe.referenceFrame, event.target.observer);
		
		// add to stage...
		Lib.current.addChild(_menu);
	}
	
	private static function switchReferenceFrameHandler(event:ContextMenuEvent):Void {
		_menu.stopTracking();
		
		
	}
}