package starling.display {
	
	import flash.utils.Dictionary;
	
	import starling.core.RenderSupport;
	import starling.filters.FragmentFilter;
	
	/**
	 * Container for LayeredObjects. It displays only those 
	 * DisplayObjects that are linked to existing layer within 
	 * some LayeredObject.
	 * 
	 * @author Vladimir Atamanov
	 */
	public class LayeredContainer extends DisplayObjectContainer {
		
		private static const LIST_OBJECTS_POOL:Vector.<Vector.<ListObject>> = new Vector.<Vector.<ListObject>>();
		
		private var _layers:Vector.<String>;
		private var _listObjectsByName:Dictionary;
		
		public function LayeredContainer() {
			
			_layers = new Vector.<String>();
			_listObjectsByName = new Dictionary();
			
		}
		
		/**
		 * Creates new layer on top of all others.
		 * If layer with such name already exists then
		 * nothing happens.
		 */
		public function createLayer(layerName:String):void {
			
			var index:int = _layers.indexOf(layerName);
			if (index == -1) _layers.push(layerName);
			
		}
		
		/**
		 * Deletes layer. That does not remove  
		 * DisplayObjects from child LayeredObjects.
		 */
		public function deleteLayer(layerName:String):void {
			
			var index:int = _layers.indexOf(layerName);
			if (index != -1) {
				var length:int = _layers.length;
				for (var i:int = index + 1; i < length; ++i) {
					_layers[i - 1] = _layers[i];
				}
				--_layers.length;
			}
			
		}
		
		public override function render(support:RenderSupport, parentAlpha:Number):void {
			
			var alpha:Number = parentAlpha * this.alpha;
			var blendMode:String = support.blendMode;
			
			var numLayers:int = _layers.length;
			for (var i:int = 0; i < numLayers; ++i) {
				var layerName:String = _layers[i];
				var listObjects:Vector.<ListObject> = _listObjectsByName[layerName];
				if (listObjects == null) continue;
				
				var numListObjects:int = listObjects.length;
				for (var j:int = 0; j < numListObjects; ++j) {
					var listObject:ListObject = listObjects[j];
					var layeredObject:LayeredObject = listObject.layeredObject;
					if (layeredObject.hasVisibleArea) {
						var filter:FragmentFilter = layeredObject.filter;
						support.pushMatrix();
						support.transformMatrix(layeredObject);
						support.blendMode = layeredObject.blendMode;
						
						if (filter != null) {
							filter.render(layeredObject, support, alpha);
						} else {
							layeredObject.renderList(listObject.list, support, alpha);
						}
						
						support.blendMode = blendMode;
						support.popMatrix();
					}
				}
			}
			
		}
		
		public override function dispose():void {
			
			super.dispose();
			
			for (var layerName:String in _listObjectsByName) {
				var listObjects:Vector.<ListObject> = _listObjectsByName[layerName];
				listObjects.length = 0;
				LIST_OBJECTS_POOL.push(listObjects);
			}
			
		}
		
		internal function addListObject(listObject:ListObject):void {
			
			var listObjects:Vector.<ListObject> = _listObjectsByName[listObject.layerName];
			if (listObjects == null) {
				if (LIST_OBJECTS_POOL.length == 0) {
					listObjects = new Vector.<ListObject>();
				} else {
					listObjects = LIST_OBJECTS_POOL.pop();
				}
				_listObjectsByName[listObject.layerName] = listObjects;
			}
			
			listObjects.push(listObject);
			
		}
		
		internal function removeListObject(listObject:ListObject):void {
			
			var listObjects:Vector.<ListObject> = _listObjectsByName[listObject.layerName];
			var length:int = listObjects.length;
			var index:int = listObjects.indexOf(listObject);
			for (var i:int = index + 1; i < length; ++i) {
				listObjects[i - 1] = listObjects[i];
			}
			--listObjects.length;
			if (listObjects.length == 0) {
				LIST_OBJECTS_POOL.push(listObjects);
				delete _listObjectsByName[listObject.layerName];
			}
			
		}
		
	}
	
}