package starling.display
{
    import flash.utils.Dictionary;

    /**
     * Object that holds together several DisplayObjects on
     * different layers. Order of display depends on parent
     * LayeredContainer.
     *
     * @author Vladimir Atamanov
     */
    public class LayeredObject extends Sprite
    {
        private static const LIST_OBJECT_POOL:Vector.<ListObject> = new <ListObject>[];

        private const _listObjects:Vector.<ListObject> = new <ListObject>[];
        private const _listObjectByName:Dictionary = new Dictionary();
        private const _listObjectByDisplayObject:Dictionary = new Dictionary();
        private const _layeredDisplayObjects:Vector.<DisplayObject> = new <DisplayObject>[];
        private const _nestedLayeredObjects:Vector.<LayeredObject> = new <LayeredObject>[];

        private var _container:LayeredContainer;

        public function LayeredObject()
        {
            super();
        }

        /**
         * Add DisplayObject and link it to layer.
         */
        public function addChildToLayer(displayObject:DisplayObject, layerName:String):DisplayObject
        {
            if (displayObject.parent != this)
            {
                var listObject:ListObject = _listObjectByName[layerName];
                if (listObject == null)
                {
                    listObject = LIST_OBJECT_POOL.pop() || new ListObject();
                    listObject.layerName = layerName;
                    listObject.layeredObject = this;
                    _listObjects.push(listObject);
                    if (_container != null)
                        _container.addListObject(listObject);
                }

                listObject.list.push(displayObject);
                _listObjectByDisplayObject[displayObject] = listObject;
                _layeredDisplayObjects.push(displayObject);
            }
            return addChild(displayObject);
        }

        override public function addChildAt(child:DisplayObject, index:int):DisplayObject
        {
            var displayObject:DisplayObject = super.addChildAt(child, index);
            var layeredObject:LayeredObject = displayObject as LayeredObject;
            if (layeredObject != null)
            {
                index = _nestedLayeredObjects.indexOf(layeredObject);
                if (index == -1)
                {
                    _nestedLayeredObjects[_nestedLayeredObjects.length] = layeredObject;
                    layeredObject.setContainer(_container);
                }
            }
            return displayObject;
        }

        override public function removeChildAt(index:int, dispose:Boolean = false):DisplayObject
        {
            var displayObject:DisplayObject = super.removeChildAt(index, dispose);

            var length:int;
            var i:int;

            var listObject:ListObject = _listObjectByDisplayObject[displayObject];
            if (listObject != null)
            {
                delete _listObjectByDisplayObject[displayObject];

                // Remove from display objects.
                length = _layeredDisplayObjects.length;
                index = _layeredDisplayObjects.indexOf(displayObject);
                for (i = index + 1; i < length; ++i)
                    _layeredDisplayObjects[i - 1] = _layeredDisplayObjects[i];
                --_layeredDisplayObjects.length;

                var list:Vector.<DisplayObject> = listObject.list;

                // Remove from list object.
                length = list.length;
                index = list.indexOf(displayObject);
                for (i = index + 1; i < length; ++i)
                    list[i - 1] = list[i];
                --list.length;

                // Return to pool if necessary.
                if (list.length == 0)
                {
                    if (_container != null)
                        _container.removeListObject(listObject);
                    listObject.layerName = null;
                    listObject.layeredObject = null;
                    LIST_OBJECT_POOL.push(listObject);
                    length = _listObjects.length - 1;
                    index = _listObjects.indexOf(listObject);
                    _listObjects[index] = _listObjects[length];
                    _listObjects.length = length;
                }
            }

            var layeredObject:LayeredObject = displayObject as LayeredObject;
            if (layeredObject != null)
            {
                index = _nestedLayeredObjects.indexOf(layeredObject);
                if (index != -1)
                {
                    length = _nestedLayeredObjects.length - 1;
                    _nestedLayeredObjects[index] = _nestedLayeredObjects[length];
                    _nestedLayeredObjects.length = length;
                    layeredObject.setContainer(null);
                }
            }

            return displayObject;
        }

        override public function dispose():void
        {
            super.dispose();

            while (_listObjects.length != 0)
            {
                var listObject:ListObject = _listObjects.pop();
                listObject.layerName = null;
                listObject.layeredObject = null;
                listObject.list.length = 0;
                LIST_OBJECT_POOL.push(listObject);
            }
        }

        override internal function setParent(value:DisplayObjectContainer):void
        {
            setContainer(value as LayeredContainer);
            super.setParent(value);
        }

        [Inline]
        private final function setContainer(value:LayeredContainer = null):void
        {
            for each (var listObject:ListObject in _listObjects)
            {
                if (_container != null)
                    _container.removeListObject(listObject);
                if (value != null)
                    value.addListObject(listObject);
            }
            for each (var layeredObject:LayeredObject in _nestedLayeredObjects)
                layeredObject.setContainer(value);
            _container = value;
        }

        [Inline]
        internal final function getListObject(layerName:String):ListObject
        {
            return _listObjectByName[layerName];
        }

        [Inline]
        internal final function getAlphaBeforeContainer():Number
        {
            var result:Number = 1.0;
            var parent:DisplayObject = this.parent;
            while (parent != _container && parent != null)
            {
                result *= parent.alpha;
                parent = parent.parent;
            }
            return result;
        }
    }
}